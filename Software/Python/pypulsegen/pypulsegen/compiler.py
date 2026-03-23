from dataclasses import dataclass
import numpy as np
import matplotlib.pylab as plt

try:
    from .lexer import Lexer
    from .parser import Parser, TimeDefinitionNode, IdentifierNode, NumberNode, PulseNode, DelayNode
except:
    from lexer import Lexer
    from parser import Parser, TimeDefinitionNode, IdentifierNode, NumberNode, PulseNode, DelayNode

PULSE_CONFIG = {
    'pulse': {
        'source': 'pulse',
        'bit': 0,
        'lead': 0e-9,
        'lag': 0e-9,
        'connectivity': 0e-9,
        'inverted': False,
        },
    'AMP GATE': {
        'source': 'pulse',
        'bit': 1,
        'lead': 120e-9,
        'lag': 0e-9,
        'connectivity': 1000e-9,
        'inverted': False
        },
    'PROTECT':{
        'source': 'pulse',
        'bit': 2,
        'lead': 100e-9,
        'lag': 100e-9,
        'connectivity': 500e-9,
        'inverted': True
        },
    'detect':{
        'source': 'detect',
        'bit': 3,
        'lead': 0e-9,
        'lag': 0e-9,
        'connectivity': 0e-9,
        'inverted': False
        },
}

RESOLUTION = 4e-9
REP_TIME = 10e-3  # Repetition time in seconds
MIN_DELAY = 0  # Minimum delay in clock cycles (2 clock cycle = 4 ns for 250 MHz clock)

@dataclass
class Instruction: # 80-bit programming word of FPGA
    addr: int
    pulse_pattern: int
    data: int # used for goto, long_delay, etc.
    op_code: int # e.g., NOOP, DELAY, LONG_DELAY, GOTO, WAIT
    delay: int # clock cycles to delay

@dataclass
class Edge:
    name: str
    time: float
    bit: int
    state: int # 1 for rising, 0 for falling
    inverted: bool

@dataclass
class State:
    pulse_pattern: int
    delay: float

def locate_master_edges(ast, pulse_config, parameters):
    edges = []
    current_time = 0
    for node in ast:
        if isinstance(node, TimeDefinitionNode):
            # Handle time definitions
            pass
        elif isinstance(node, PulseNode):
            name = node.name
            if name not in pulse_config:
                raise Exception(f"Undefined pulse: {name}")
            if isinstance(node.duration, IdentifierNode):
                duration_value = parameters.get(node.duration.duration, None)
                if duration_value is None:
                    raise Exception(f"Undefined parameter: {node.duration.duration}")
                edges.append(Edge(name = name, time=current_time, bit=pulse_config[name]['bit'], state=1, inverted=pulse_config[name]['inverted']))  # Rising edge
                current_time += duration_value
                edges.append(Edge(name = name, time=current_time, bit=pulse_config[name]['bit'], state=0, inverted=pulse_config[name]['inverted']))  # Falling edge
            elif isinstance(node.duration, NumberNode):
                edges.append(Edge(name = name, time=current_time, bit=pulse_config[name]['bit'], state=1, inverted=pulse_config[name]['inverted']))  # Rising edge
                current_time += node.duration.duration
                edges.append(Edge(name = name, time=current_time, bit=pulse_config[name]['bit'], state=0, inverted=pulse_config[name]['inverted']))  # Falling edge
        elif isinstance(node, DelayNode):
            if isinstance(node.duration, IdentifierNode):
                duration_value = parameters.get(node.duration.duration, None)
                if duration_value is None:
                    raise Exception(f"Undefined parameter: {node.duration.duration}")
                current_time += duration_value
            elif isinstance(node.duration, NumberNode):
                current_time += node.duration.duration
    return edges

def locate_derived_edges(master_edges, pulse_config, parameters):
    derived_edges = []
    for edge in master_edges:
        name = edge.name
        for derived_name, derived_info in pulse_config.items():
            print(derived_name)
            print(derived_info)
            if derived_name == name:
                pass # this is master channel
            elif (pulse_config[derived_name]['source'] == name):
                if edge.state == 1:  # Rising edge
                    derived_edges.append(Edge(name=derived_name, time=edge.time - derived_info['lead'], bit=derived_info['bit'], state=1, inverted=derived_info['inverted']))
                else:  # Falling edge
                    derived_edges.append(Edge(name=derived_name, time=edge.time + derived_info['lag'], bit=derived_info['bit'], state=0, inverted=derived_info['inverted']))
    return derived_edges

def remove_redundant_edges(edges, pulse_config):
    updated_edges = []
    for name in pulse_config: # for master channels
        last_state = 0
        for edge in edges:
            if edge.name == name:
                if edge.state == 1:  # Rising edge
                    if last_state == 0:
                        print(f'Adding edge: {edge}')
                        updated_edges.append(edge)
                        last_state = 1
                    else:
                        print(f'Skipping edge due to double rising edges: {edge}')
                        pass  # Skip this rising edge due to connectivity constraint
                else: # Falling edge
                    if last_state == 1:
                        print(f'Adding edge: {edge}')
                        updated_edges.append(edge)
                        last_state = 0
                    else:                                
                        print(f'Skipping edge due to double falling edges: {edge}')
                        pass
            else:
                pass

    return updated_edges

def connect_edges(edges, pulse_config):
    updated_edges = []
    for name in pulse_config: # for master channels
        connectivity_time = pulse_config[name]['connectivity']

        last_falling_edge_time = -1
        for edge in edges:
            if edge.name == name:
                if edge.state == 0:
                    last_falling_edge_time = edge.time
                    updated_edges.append(edge)
                if edge.state == 1:
                    if (edge.time - last_falling_edge_time) < connectivity_time:
                        junk = updated_edges.pop()
                    else:
                        updated_edges.append(edge)

    return updated_edges

def locate_edges(ast, pulse_config, parameters):
    master_edges = locate_master_edges(ast, pulse_config, parameters)
    slave_edges = locate_derived_edges(master_edges, pulse_config, parameters)
    edges = master_edges + slave_edges
    # edges.sort(key=lambda x: x.time)  # Sort edges by time
    # edges = connect_edges(edges, pulse_config)
    edges.sort(key=lambda x: x.time)  # Sort edges by time
    edges = remove_redundant_edges(edges, pulse_config)
    edges.sort(key=lambda x: x.time)  # Sort edges by time
    edges = connect_edges(edges, pulse_config)
    edges.sort(key=lambda x: x.time)  # Sort edges by time
    return edges

def edges_to_states(edges, pulse_config):
    if not edges:
        return [State(pulse_pattern=0, delay=0)]

    states = []
    current_pattern = 0
    i = 0
    n = len(edges)

    # Initial idle period (0 → first edge)
    if edges[0].time > 0:
        state = State(pulse_pattern=0, delay=edges[0].time)
        print(f'Initial: 00000000 holds {edges[0].time*1e9:.1f} ns')
        states.append(state)

    while i < n:
        curr_time = edges[i].time
        print(f'\nChange at {curr_time*1e9:.1f} ns:')

        # Apply ALL edges that happen at exactly this timestamp (handles simultaneous slaves)
        while i < n and np.isclose(edges[i].time, curr_time, atol=1e-10):
            edge = edges[i]
            if edge.state == 1:
                current_pattern |= (1 << edge.bit)
            else:
                current_pattern &= ~(1 << edge.bit)
            print(f'   {edge.name} {"↑" if edge.state==1 else "↓"} bit{edge.bit} → {current_pattern:08b}')
            i += 1

        # Compute hold time until next change (last one gets 0)
        if i < n:
            delay = edges[i].time - curr_time
        else:
            delay = 0.0
            print(f'   → Final change to {current_pattern:08b}')
            states.append(State(pulse_pattern=current_pattern, delay=0))
            break

        state = State(pulse_pattern=current_pattern, delay=delay)
        print(f'   → Holds {current_pattern:08b} for {delay*1e9:.1f} ns')
        states.append(state)

    get_inverted_bits(pulse_config)

    for state in states:
        for name, info in pulse_config.items():
            if info['inverted']:
                state.pulse_pattern ^= (1 << info['bit'])
    return states

def get_inverted_bits(pulse_config):
    inverted_bits = set()
    for name, info in pulse_config.items():
        if info.get('inverted', False):
            inverted_bits.add(info['bit'])
    return inverted_bits

def generate_instructions(states, config):
    ''' Create instruction list from states
    '''
    START_ADDR = 0
    # RESOLUTION = config.resolution
    addr = START_ADDR
    inverted_bits = get_inverted_bits(config)
    initial_pulse_pattern = states[0].pulse_pattern

    instructions = []

    total_time = 0
    for state in states:
        delay = state.delay
        cycles = round((delay)/RESOLUTION) - 2 # Changed to 2 due to limitation of 2 clock cycle minimum pulse length
        if cycles < MIN_DELAY:
            print(f"Warning: enforced min delay {MIN_DELAY} cycles "
                  f"(was {cycles}) at pattern {state.pulse_pattern:08b}")
            cycles = MIN_DELAY
        inst = Instruction(addr = addr, pulse_pattern = state.pulse_pattern, data = 0, op_code = 1, delay = cycles)
        instructions.append(inst)
        total_time += delay
        addr += 1

    rep_delay_cycles = round((REP_TIME - total_time)/RESOLUTION) - 2
    rep_inst = Instruction(addr=addr, pulse_pattern=initial_pulse_pattern, data=0, op_code=1, delay=rep_delay_cycles)
    instructions.append(rep_inst)
    # add jump
    jump_inst = Instruction(addr=addr+1, pulse_pattern=initial_pulse_pattern, data=0, op_code=3, delay=0)
    instructions.append(jump_inst)

    # for inst in instructions:
    #     # Apply inversion to this pattern
    #     pattern_out = inst.pulse_pattern
    #     for bit in inverted_bits:
    #         pattern_out ^= (1 << bit)
    #     inst.pulse_pattern = pattern_out

    return instructions

def compile_ast(ast, pulse_config, parameters):
    edges = locate_edges(ast, pulse_config, parameters)
    states = edges_to_states(edges, pulse_config)
    instructions = generate_instructions(states, pulse_config)

    return instructions

def instructions_to_bytes(instructions):

    inst_bytes = []

    for inst in instructions:
        addr = inst.addr
        pulse = inst.pulse_pattern
        data = inst.data
        op_code = inst.op_code
        delay = inst.delay

        inst_data = (pulse << 56) + (data << 36) + (op_code << 32) + delay
        inst_data_bytes = inst_data.to_bytes(8, byteorder = 'big')
        inst_addr_bytes = ((1<<12) + addr).to_bytes(2, byteorder = 'big')

        inst_word = inst_addr_bytes + inst_data_bytes
        
        inst_bytes.append(inst_word)

    return inst_bytes

def plot_states(states, n_bits = 8):
    times = [0.0]
    
    # Build cumulative time axis
    for s in states:
        times.append(times[-1] + s.delay*1e6)

    # For each bit, build waveform
    for bit in range(n_bits):
        y = []

        for s in states:
            val = ((s.pulse_pattern >> bit) & 1)*0.95 # scale down for better visualization
            y.append(val + bit)  # offset by bit index

        # Repeat last value for step plotting
        y.append(y[-1])

        plt.step(times, y, where='post')

    plt.xlabel(u"Time (\u03bcs)")
    plt.ylabel("Bit index (offset)")
    plt.title("Pulse Pattern States")
    plt.grid(True)

    plt.show()

if __name__ == "__main__":
    pulse_program = \
"""
time tau, p1, p90, p180 # this is a comment

delay 1000 ns
pulse 8 ns
delay tau
pulse 16 ns
delay tau
detect 40 ns
delay 1 us
"""
    lexer = Lexer(pulse_program)
    tokens = lexer.tokenize()
    print('Tokens:')
    for token in tokens:
        print(token)
    
    print('\nParsing Output...')
    parser = Parser(tokens)
    nodes = parser.parse()
    print('\nNodes:')
    for node in nodes:
        print(node)
    print('Done.')

    parameters = {'tau': 208e-9, 'p1': 2e-6, 'p90': 4e-6}

    print('\nCompiling...')

    edges = locate_edges(nodes, PULSE_CONFIG, parameters)
    print('\nEdges:')
    for edge in edges:
        print(edge)

    print('\nStates:')
    states = edges_to_states(edges, PULSE_CONFIG)
    for state in states:
        print(f'{state.pulse_pattern:08b}', f'{state.delay*1e9:6.0f} ns')
    

    # instructions = edges_to_instructions(states, PULSE_CONFIG)
    instructions = generate_instructions(states, PULSE_CONFIG)
    print('\nInstructions:')
    for inst in instructions:
        # print(bin(inst.pulse_pattern), bin(inst.delay))
        print(f"{inst.pulse_pattern:08b}, {inst.delay:32b}")
    #  out = compile(nodes, PULSE_CONFIG, parameters)
    inst_bytes = instructions_to_bytes(instructions)

    print()
    print('-'*89)
    print('INSTRUCTION BYTES')
    print('-'*89)
    print('COM||ADD R------| |PULSE-| |DATA--- -------- ---||OP| |DELAY->')

    for inst_byte in inst_bytes:
        # print(bin(inst_byte))
        binary_string = ' '.join(f'{byte:08b}' for byte in inst_byte)
        print(binary_string)
    print('Done.')
    import hardware
    print('\nUploading sequence to FPGA Pulse Programmer...')
    hardware.upload_sequence(inst_bytes)
    print('Sequence uploaded to FPGA Pulse Programmer.')
    plot_states(states, 4)
