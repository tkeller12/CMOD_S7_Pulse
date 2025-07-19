from dataclasses import dataclass
from typing import List, Dict, Tuple, Set
import copy


RESOLUTION = 4e-9 # pulse programmer time resolution
START_ADDR = 1
CHANNELS = [f'CH{ix}' for ix in range(8)]

@dataclass
class Edge:
    time: float
    channel: str
    state: int # 1 for rising, 0 for falling

@dataclass
class Instruction: # 80-bit programming word of FPGA
    command: int
    addr: int
    pulse_pattern: str
    DDS: int # specifies DDS Pulse Phase
    data: int # used for goto, long_delay, etc.
    op_code: int # e.g., NOOP, DELAY, LONG_DELAY, GOTO, WAIT
    delay: int # clock cycles to delay (0 -> 1 clock cycle)

@dataclass
class Command:
    name: str # e.g., NOOP, DELAY, GOTO, WAIT, LONG_DELAY
    duration: float
    data: int = 0 # used for goto, long_delay, etc.


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
#            edge.channel = 1 << edge.channel
#            new_edge = Edge(time = edge.time, channel = 1<<edge.channel, state = edge.state<<edge.channel)
#            new_edge = Edge(time = edge.time, channel = -1, state = edge.state<<edge.channel)
#            new_edge = Edge(time = edge.time, channel = edge.channel, state = edge.state<<edge.channel)
#            all_edges.append(new_edge)
            all_edges.append(edge)

    sorted_edges = sorted(all_edges, key = lambda x: x.time)
    return sorted_edges

def compile_states(sorted_edges):
    '''Edges must be converted to states
    '''
    initial_state = 0b0000000
    previous_state = initial_state
    sorted_edges = copy.deepcopy(sorted_edges) # why? because I do: edge.channel = 1 << edge.channel
    compiled_states = []
    previous_time = 0
    for edge in sorted_edges:
        print(edge)
        time = edge.time
        if time != previous_time:
            if edge.state == 1: # Rising Edge, need OR with bitmask
                bitmask = 1<<edge.channel
                state = previous_state | bitmask
            else: # falling edge, need AND
                bitmask = ~(1<<edge.channel)
                state = previous_state & bitmask
            line = Edge(time = time, channel = -1, state = state)
            compiled_states.append(line)
            previous_time = time
            previous_state = state
        else:
            popped_line = compiled_states.pop()
            if edge.state == 1: # Rising Edge, need OR with bitmask
                bitmask = 1<<edge.channel
                state = previous_state | bitmask
#                compiled_states.append(edge)
            else: # falling edge, need AND
                bitmask = ~(1<<edge.channel)
                state = previous_state & bitmask
            line = Edge(time = time, channel = -1, state = state)
            compiled_states.append(line)
            previous_time = time
            previous_state = state

#            current_state = edge.state + popped_edge.state
#            compiled_edges.append(Edge(time = edge.time, channel = -1, state = current_state))

    return compiled_states

def instructions_to_bytes(instruction: Instruction) -> List[bytes]:
    print('')

    return inst_bytes

def main():
    pulse_program = '''
    delay 1000e-9
    pulse 100e-9
    delay 1000e-9
    pulse 200e-9
    delay 10e-6
    '''

    alias = {'CH0':'TX',
             'CH1':'AMP',
             'CH2':'RX'
             }

    leads = {
            'CH0': 0,
            'CH1': 100e-9,
            'CH2': 200e-9,
            'CH3': 0,
            'CH4': 0,
            'CH5': 0,
            'CH6': 0,
            'CH7': 0,
            }

    lags = {
            'CH0': 0,
            'CH1': 100e-9,
            'CH2': 200e-9,
            'CH3': 0,
            'CH4': 0,
            'CH5': 0,
            'CH6': 0,
            'CH7': 0,
            }

    connectivity = {
            'CH0': 0,
            'CH1': 0e-9,
            'CH2': 0e-9,
            'CH3': 0,
            'CH4': 0,
            'CH5': 0,
            'CH6': 0,
            'CH7': 0,
            }

    active_channels = ['CH0', 'CH1', 'CH2']

    inverted_channels = ['RX'] # Not implemented


    commands = parse_pulse_program(pulse_program)
    master_edges = locate_master_edges(commands)
    edges = locate_edges(master_edges, active_channels, leads, lags)
    updated_edges = merge_edges_connectivity(edges, connectivity)#, active_channels, leads, lags)
    sorted_edges = sort_edges(updated_edges)
    all_states = compile_states(sorted_edges)


    print('-'*50)
    print('PULSE PROGRAM')
    print('-'*50)
    for line in pulse_program.strip().split('\n'):
        print(line.strip())

    print('-'*50)
    print('COMMANDS')
    print('-'*50)
    for command in commands:
        print(command)

    print('-'*50)
    print('MASTER EDGES')
    print('-'*50)
    for edge in master_edges:
        print(edge)

    print('-'*50)
    print('EDGES')
    print('-'*50)
    for channel in edges:
        print(' CHANNEL: ' + channel)
        for edge in edges[channel]:
            print(' ', edge)

    print('-'*50)
    print('UPDATED EDGES')
    print('-'*50)
    for channel in updated_edges:
        suffix = ''
        if channel in alias:
            suffix = ', ' + alias[channel]
        print(' CHANNEL: ' + channel + suffix)
        for edge in updated_edges[channel]:
            print(' ', edge)

    print('-'*50)
    print('SORTED EDGES')
    print('-'*50)
    for edge in sorted_edges:
        print(edge)
#        print(edge, edge.time.)
#        print(f'{edge.time:0{4}e}', f'{edge.state:0{8}b}')

    print('-'*50)
    print('ALL EDGES')
    print('-'*50)
    for states in all_states:
        print(f'{states.time:0{4}e}', f'{states.state:0{8}b}')

if __name__ == '__main__':
    main()
