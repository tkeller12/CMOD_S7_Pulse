#from dataclasses import dataclass
from typing import List, Dict, Tuple, Set
from .types import Edge, Instruction, Command, Config
import copy
import math
import json

#RESOLUTION = 8e-9 # pulse programmer time resolution
#START_ADDR = 1
CHANNELS = [f'CH{ix}' for ix in range(8)]

def parse_pulse_program(pulse_program):
    '''convert pulse program into list of commands with delays
    '''
    lines = pulse_program.split('\n')
    commands = []
    for line in lines:
        proc_line = line.strip()
        if proc_line != '':
            command, delay = proc_line.split(' ') # NO support for Long delay
            if command.strip().upper() == 'DELAY':
                commands.append(Command(name = 'DELAY', duration = float(delay), data = 0))

            elif command.strip().upper() == 'PULSE':
                commands.append(Command(name = 'PULSE', duration = float(delay), data = 0))
            else:
                raise ValueError('Non-supported command found: %s'%command)
    return commands

def locate_master_edges(commands:List[Command]) -> List[Edge]:
    time = 0
    master_edges = []
    for command in commands:
        if command.name == 'DELAY':
            time = time + command.duration
        if command.name == 'PULSE':
            master_edges.append(Edge(time = time, channel = -1, state = 1)) #-1 is master channel
            master_edges.append(Edge(time = time+command.duration, channel = -1, state = 0)) #-1 is master channel
    return master_edges

def locate_edges(master_edges:List[Edge], active_channels:List[str], leads, lags) -> List[Edge]:
    edges = {}
    for channel in active_channels:
        edges[channel] = []
        for master_edge in master_edges:
            if master_edge.state == 1:
                edges[channel].append(Edge(time = master_edge.time - leads[channel], channel = CHANNELS.index(channel), state = 1))
            if master_edge.state == 0:
                edges[channel].append(Edge(time = master_edge.time + lags[channel], channel = CHANNELS.index(channel), state = 0))

    return edges

def merge_edges_connectivity(channel_edges:Dict[str,Edge], connectivity):

    edges = {}
    for channel in channel_edges:
        last_falling_edge_time = -1
        updated_channel_edges = []
        for edge in channel_edges[channel]:
            if edge.state == 0:
                last_falling_edge_time = edge.time
                updated_channel_edges.append(edge)
            if edge.state == 1:
                if (edge.time - last_falling_edge_time) < connectivity[channel]:
                    junk = updated_channel_edges.pop()
                else:
                    updated_channel_edges.append(edge)

        edges[channel] = updated_channel_edges
    return edges

def sort_edges(updated_channel_edges):
    updated_channel_edges = copy.deepcopy(updated_channel_edges) # why? because I do: edge.channel = 1 << edge.channel
    all_edges = []
    for channel in updated_channel_edges:
        for edge in updated_channel_edges[channel]:
            all_edges.append(edge)

    sorted_edges = sorted(all_edges, key = lambda x: x.time)
    return sorted_edges

def compile_states(sorted_edges, inverted_channels, rep_time):
    '''Edges must be converted to states
    '''
    initial_state = 0
    final_state = 0
    previous_state = initial_state
    sorted_edges = copy.deepcopy(sorted_edges) # why?
    compiled_states = []
    previous_time = 0
    for edge in sorted_edges:
#        print('-'*50)
#        print(edge)
        time = edge.time
#        if time != previous_time:
        if not math.isclose(time, previous_time):
#            print('New Time: ', time)
            if edge.state == 1: # Rising Edge, need OR with bitmask
                bitmask = 1<<edge.channel
                state = previous_state | bitmask
            else: # falling edge, need AND
                bitmask = ~(1<<edge.channel)
                state = previous_state & bitmask
#            line = Edge(time = time, channel = -1, state = state)
            line = Edge(time = time-previous_time, channel = -1, state = state)
#            line = Edge(time = previous_time, channel = -1, state = state)
            compiled_states.append(line)
            previous_time = time
            previous_state = state
            delta_time = time - previous_time
        else:
#            print('Old Time: ', time)
            popped_line = compiled_states.pop()
#            popped_time = popped_line.time
#            print('popped line', popped_line)

            if edge.state == 1: # Rising Edge, need OR with bitmask
                bitmask = 1<<edge.channel
                state = previous_state | bitmask
            else: # falling edge, need AND with ~bitmask
                bitmask = ~(1<<edge.channel)
                state = previous_state & bitmask
            line = Edge(time = popped_line.time, channel = -1, state = state)
#            print('updated line', line)
#            line = Edge(time = delta_time, channel = -1, state = state)

#            line = Edge(time = previous_time, channel = -1, state = state)
            compiled_states.append(line)
            previous_time = time
            previous_state = state

    # ugly hack
    durations = []
    pulse_patterns = [0]
    total_time = 0
    for state in compiled_states:
        durations.append(state.time)
        total_time += state.time
        pulse_patterns.append(state.state)




    durations.append(rep_time - total_time)

    #This loop is a crazy hack for inverting 
    for ix in range(len(pulse_patterns)):
        for channel in inverted_channels:
            channel_ix = CHANNELS.index(channel)
            mask = 1<<channel_ix
            pulse_patterns[ix] = pulse_patterns[ix] ^ mask


    compiled_states_fixed = []
    for ix in range(len(durations)):
        compiled_states_fixed.append(Edge(time = durations[ix], channel = -1, state = pulse_patterns[ix]))

    return compiled_states_fixed

def generate_instructions(states, config):
    ''' Create instruction list from states
    '''
    START_ADDR = config.start_addr
    RESOLUTION = config.resolution
    addr = START_ADDR

    instructions = []

    for state in states:
        delay = state.time
        cycles = round((delay)/RESOLUTION) - 1
        inst = Instruction(addr = addr, pulse_pattern = state.state, data = 0, op_code = 1, delay = cycles)
        instructions.append(inst)
        addr += 1

    # add goto
    instructions.append(Instruction(addr = addr, pulse_pattern = 0, data = 1, op_code = 3, delay = 0))

    return instructions

def instructions_to_bytes(instructions: List[Instruction]) -> List[bytes]:

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

def load_config_from_json(file_path: str) -> Config:
    with open(file_path, 'r') as f:
        data = json.load(f)
    return Config(
        leads={k: float(v) for k, v in data['leads'].items()},
        lags={k: float(v) for k, v in data['lags'].items()},
        connectivity={k: float(v) for k, v in data['connectivity'].items()},
        active_channels=data['active_channels'],
        inverted_channels=data['inverted_channels'],
        rep_time=float(data['rep_time']),
        alias=data.get('alias', {}),
        resolution=float(data.get('resolution', 8e-9)),
        start_addr=int(data.get('start_addr', 1))
    )

def compile_pulse_program(pulse_program: str, config: Config):

    commands = parse_pulse_program(pulse_program)
    master_edges = locate_master_edges(commands)
    edges = locate_edges(master_edges, config.active_channels, config.leads, config.lags)
    updated_edges = merge_edges_connectivity(edges, config.connectivity)
    sorted_edges = sort_edges(updated_edges)
    all_states = compile_states(sorted_edges, config.inverted_channels, config.rep_time)
    instructions = generate_instructions(all_states, config)
    inst_bytes = instructions_to_bytes(instructions)

    return inst_bytes

if __name__ == '__main__':
    pass
