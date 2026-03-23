from dataclasses import dataclass
import numpy as np

try:
    from .lexer import Lexer
    from .parser import Parser, TimeDefinitionNode, IdentifierNode, NumberNode, PulseNode, DelayNode
except:
    from lexer import Lexer
    from parser import Parser, TimeDefinitionNode, IdentifierNode, NumberNode, PulseNode, DelayNode

PULSE_CONFIG = {
    'pulse': {
        'channel': 'CH0',
        'bit': 0,
        'lead': 0e-9,
        'lag': 0e-9,
        'connectivity': 0e-9,
        'inverted': False,
        'slave_channels': {
            'AMP GATE': {
            'channel': 'CH1',
            'bit': 1,
            'lead': 100e-9,
            'lag': 100e-9,
            'connectivity': 300e-9,
            'inverted': False
            },
            'PROTECT': {
            'channel': 'CH2',
            'bit': 2,
            'lead': 100e-9,
            'lag': 100e-9,
            'connectivity': 200e-9,
            'inverted': True
            }
        }
    },
    'detect': {
        'channel': 'CH3',
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
    channel: str
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
                edges.append(Edge(name = name, time=current_time, channel=pulse_config[name]['channel'], bit=pulse_config[name]['bit'], state=1, inverted=pulse_config[name]['inverted']))  # Rising edge
                current_time += duration_value
                edges.append(Edge(name = name, time=current_time, channel=pulse_config[name]['channel'], bit=pulse_config[name]['bit'], state=0, inverted=pulse_config[name]['inverted']))  # Falling edge
            elif isinstance(node.duration, NumberNode):
                edges.append(Edge(name = name, time=current_time, channel=pulse_config[name]['channel'], bit=pulse_config[name]['bit'], state=1, inverted=pulse_config[name]['inverted']))  # Rising edge
                current_time += node.duration.duration
                edges.append(Edge(name = name, time=current_time, channel=pulse_config[name]['channel'], bit=pulse_config[name]['bit'], state=0, inverted=pulse_config[name]['inverted']))  # Falling edge
        elif isinstance(node, DelayNode):
            if isinstance(node.duration, IdentifierNode):
                duration_value = parameters.get(node.duration.duration, None)
                if duration_value is None:
                    raise Exception(f"Undefined parameter: {node.duration.duration}")
                current_time += duration_value
            elif isinstance(node.duration, NumberNode):
                current_time += node.duration.duration
    return edges

def locate_slave_edges(master_edges, pulse_config, parameters):
    slave_edges = []
    for edge in master_edges:
        name = edge.name
        if 'slave_channels' in pulse_config[name]:

            for slave_name, slave_info in pulse_config[name]['slave_channels'].items():
                if edge.state == 1:  # Rising edge
                    slave_edges.append(Edge(name=slave_name, time=edge.time - slave_info['lead'], channel=slave_info['channel'], bit=slave_info['bit'], state=1, inverted=slave_info['inverted']))
                    slave_edges.append(Edge(name=slave_name, time=edge.time + parameters.get(slave_name, 0) + slave_info['lag'], channel=slave_info['channel'], bit=slave_info['bit'], state=0, inverted=slave_info['inverted']))
                else:  # Falling edge
                    slave_edges.append(Edge(name=slave_name, time=edge.time - slave_info['lag'], channel=slave_info['channel'], bit=slave_info['bit'], state=1, inverted=slave_info['inverted']))
                    slave_edges.append(Edge(name=slave_name, time=edge.time + slave_info['lead'], channel=slave_info['channel'], bit=slave_info['bit'], state=0, inverted=slave_info['inverted']))
    return slave_edges

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

        if 'slave_channels' in pulse_config[name]:
            for slave_name, slave_info in pulse_config[name]['slave_channels'].items():
                print(f'\nSlave channel: {slave_name}')
                last_state = 0
                for edge in edges:
                    if edge.name == slave_name:
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
    return updated_edges

def connect_edges(edges, pulse_config):
    updated_edges = []
    for name in pulse_config: # for master channels
        connectivity_time = pulse_config[name]['connectivity']

        for edge in edges:
            last_falling_edge_time = -1
            if edge.name == name:
                if edge.state == 0:
                    last_falling_edge_time = edge.time
                    updated_edges.append(edge)
                if edge.state == 1:
                    if (edge.time - last_falling_edge_time) < connectivity_time:
                        junk = updated_edges.pop()
                    else:
                        updated_edges.append(edge)

        if 'slave_channels' in pulse_config[name]:
            for slave_name, slave_info in pulse_config[name]['slave_channels'].items():
                connectivity_time = slave_info['connectivity']
                last_falling_edge_time = -1
                for edge in edges:
                    if edge.name == slave_name:
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
    slave_edges = locate_slave_edges(master_edges, pulse_config, parameters)
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
    states = []
    time = 0
    initial_state = 0
    first_edge = edges[0]

    pulse_pattern = initial_state
    if first_edge.state == 1:  # Rising edge
        pulse_pattern |= (1 << first_edge.bit)
    else:  # Falling edge
        pulse_pattern &= ~(1 << first_edge.bit)
    state = State(pulse_pattern=initial_state, delay=first_edge.time)
    print('state:', state)
    states.append(state)
    # last_time = first_edge.time
    print('first_edge:', first_edge)
    last_time = 0

    for first_edge, second_edge in zip(edges, edges[1:]):
        print('-'*50)
        print('first_edge:', first_edge)
        print('second_edge:', second_edge)
        delay = second_edge.time - last_time
        print('delay:', delay)


        if second_edge.state == 1:  # Rising edge
            pulse_pattern |= (1 << second_edge.bit)
        else:  # Falling edge
            pulse_pattern &= ~(1 << second_edge.bit)

        print('pulse_pattern:', '{0:08b}'.format(pulse_pattern))
        # state = State(pulse_pattern=pulse_pattern, delay=delay)

        # print('state:', state)
        # states.append(state)

        if np.isclose(delay*1e9, 0):
            print('Merging edge into previous instruction due to zero delay')
            state = states.pop()
            # state.pulse_pattern = state.pulse_pattern | pulse_pattern
            state.pulse_pattern = pulse_pattern
            print('New pulse_pattern:', f'{state.pulse_pattern:08b}')
        print('state:', state)
        states.append(state)
        last_time = first_edge.time
    return states

def edges_to_instructions(edges, pulse_config):
    initial_state = 0b0
    instructions = []
    start_address = 0
    inverted_bits = set()
    for channel, channel_info in pulse_config.items():
        if channel_info.get('inverted'):
            inverted_bits.add(channel_info['bit'])
        if "slave_channels" in channel_info:
            for slave_channel, slave_info in channel_info['slave_channels'].items():
                if slave_info.get('inverted'):
                    inverted_bits.add(slave_info['bit'])


    print(f'Initial state: {bin(initial_state)}')
    # current_instruction = Instruction(addr=start_address, pulse_pattern=initial_state, data=0, op_code=0, delay=0)
    pulse_pattern = initial_state
    addr = start_address
    data = 0
    op_code = 1
    delay = 0

    last_time = 0


    for edge in edges:
        print('-'*50)
        print('edge:', edge)
        time = edge.time
        print('time:', time)
        delay = int((time - last_time) / RESOLUTION) - 2
        print('delay:', delay)
        if delay < MIN_DELAY:
            delay = MIN_DELAY
            print('Adjusted delay to minimum:', delay)
        if edge.state == 1:  # Rising edge
            pulse_pattern |= (1 << edge.bit)
        else:  # Falling edge
            pulse_pattern &= ~(1 << edge.bit)

        if np.isclose(time, last_time):
            print('Merging edge into previous instruction due to zero delay')
            instruction = instructions.pop()
            instruction.pulse_pattern = instruction.pulse_pattern | pulse_pattern
        else:
            instruction = Instruction(addr=addr, pulse_pattern=pulse_pattern, data=data, op_code=op_code, delay=delay)
            addr += 1

        last_time = time
        print('instruction:', instruction)
        instructions.append(instruction)

    rep_time_delay = int((REP_TIME - last_time) / RESOLUTION) - 2 # -2 for GOTO
    if rep_time_delay < MIN_DELAY:
        raise Exception(f"Repetition time is too short. Minimum repetition time is {last_time + MIN_DELAY * RESOLUTION} seconds.")

    rep_time_instruction = Instruction(addr=addr, pulse_pattern=initial_state, data=1, op_code=1, delay=rep_time_delay)
    instructions.append(rep_time_instruction)
    jump_instruction = Instruction(addr=addr+1, pulse_pattern=initial_state, data=start_address, op_code=3, delay=0)
    instructions.append(jump_instruction)

    for inst in instructions:
        for bit in inverted_bits:
            inst.pulse_pattern ^= (1 << bit)

    return instructions


def compile_ast(ast, pulse_config, parameters):
    # Placeholder for the actual compilation logic
    # This function would take the AST generated by the parser and convert it into a format suitable for execution or further processing
    instructions = []
    edges = []
    current_time = 0

    # master_edges = locate_master_edges(ast, pulse_config, parameters)
    # slave_edges = locate_slave_edges(master_edges, pulse_config, parameters)
    # edges.extend(slave_edges)
    # edges.sort(key=lambda x: x.time)  # Sort edges by time
    edges = locate_edges(ast, pulse_config, parameters)
    states = edges_to_instructions(edges, pulse_config)

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

if __name__ == "__main__":
    pulse_program = \
"""
time tau, p1, p90 # this is a comment

delay 200 ns
pulse 8 ns
delay tau
pulse 16 ns
delay tau
detect 100 ns
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

    parameters = {'tau': 40e-9, 'p1': 2e-6, 'p90': 4e-6}

    print('\nCompiling...')

    edges = locate_edges(nodes, PULSE_CONFIG, parameters)
    print('\nEdges:')
    for edge in edges:
        print(edge)

    print('\nStates:')
    states = edges_to_states(edges, PULSE_CONFIG)
    for state in states:
        print(f'{state.pulse_pattern:08b}', f'{state.delay*1e9:6.0f} ns')

    # print('\nInstructions:')
    # instructions = edges_to_instructions(edges, PULSE_CONFIG)
    # for inst in instructions:
    #     # print(bin(inst.pulse_pattern), bin(inst.delay))
    #     print(f"{inst.pulse_pattern:08b}, {inst.delay:32b}")
    # # out = compile(nodes, PULSE_CONFIG, parameters)
    # inst_bytes = instructions_to_bytes(instructions)
    # print()
    # print('-'*89)
    # print('INSTRUCTION BYTES')
    # print('-'*89)
    # print('COM||ADD R------| |PULSE-| |DATA--- -------- ---||OP| |DELAY->')

    # for inst_byte in inst_bytes:
    #     # print(bin(inst_byte))
    #     binary_string = ' '.join(f'{byte:08b}' for byte in inst_byte)
    #     print(binary_string)
    # print('Done.')
    # import hardware
    # print('\nUploading sequence to FPGA Pulse Programmer...')
    # hardware.upload_sequence(inst_bytes)
    # print('Sequence uploaded to FPGA Pulse Programmer.')