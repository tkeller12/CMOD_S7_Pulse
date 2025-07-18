import math
from dataclasses import dataclass
from typing import List, Dict, Tuple, Set

@dataclass
class Edge:
    time: float
    channel: str  # e.g., CH0, CH1, etc.
    state: int  # 1 for rising, 0 for falling

@dataclass
class Instruction:
    addr: int
    pulse_pattern: str
    op_code: str  # e.g., DELAY, GOTO, WAIT, LONG_DELAY
    duration: float
    data: int = 0  # For LONG_DELAY (n) or GOTO (target_addr)

    def __repr__(self):
        """Custom string representation for troubleshooting."""
        duration_ns = self.duration * 1e9
        if self.op_code == 'DELAY':
            return (f"Instruction(addr={self.addr}, op_code={self.op_code}, "
                    f"pulse_pattern={self.pulse_pattern}, duration={duration_ns:.0f} ns)")
        elif self.op_code == 'LONG_DELAY':
            return (f"Instruction(addr={self.addr}, op_code={self.op_code}, "
                    f"pulse_pattern={self.pulse_pattern}, n={self.data}, duration={duration_ns:.0f} ns)")
        elif self.op_code == 'WAIT':
            return (f"Instruction(addr={self.addr}, op_code={self.op_code}, "
                    f"pulse_pattern={self.pulse_pattern})")
        elif self.op_code == 'GOTO':
            return (f"Instruction(addr={self.addr}, op_code={self.op_code}, "
                    f"pulse_pattern={self.pulse_pattern}, target_addr={self.data})")
        return f"Instruction(addr={self.addr}, op_code={self.op_code}, pulse_pattern={self.pulse_pattern})"

class PulseSequenceGenerator:
    def __init__(self, channel_map: Dict[str, str], master_channel: str = 'MW', 
                 global_leads: Dict[str, float] = None, global_lags: Dict[str, float] = None,
                 connectivity: Dict[str, float] = None, clock_cycle: float = 4e-9,
                 enabled_channels: Set[str] = None):
        self.channels = [f'CH{i}' for i in range(8)]  # CH0 to CH7
        self.channel_map = channel_map  # e.g., {'MW': 'CH0', 'AMP': 'CH1', 'RX': 'CH2', 'TRIG': 'CH4'}
        self.master_channel = master_channel  # Human-readable name, e.g., 'MW'
        self.global_leads = global_leads or {name: 0 for name in channel_map}
        self.global_lags = global_lags or {name: 0 for name in channel_map}
        self.connectivity = connectivity or {ch: 100e-9 for ch in self.channels}  # Default 100ns per channel
        self.clock_cycle = clock_cycle
        self.enabled_channels = enabled_channels or set(channel_map.keys())  # Default: all mapped channels enabled
        self.instructions = []
        # Define op code mapping
        self.op_code_map = {
            'DELAY': 1,
            'LONG_DELAY': 2,
            'WAIT': 4,
            'GOTO': 3
        }

    def quantize_time(self, time: float) -> float:
        """Quantize time to the nearest clock cycle."""
        return round(time / self.clock_cycle) * self.clock_cycle

    def parse_sequence(self, sequence_text: str) -> List[Dict]:
        """Parse a text-based sequence into a list of dictionaries."""
        sequence = []
        for line in sequence_text.strip().split('\n'):
            parts = line.strip().split()
            if not parts:
                continue
            cmd = parts[0].lower()
            if cmd not in ('pulse', 'delay'):
                raise ValueError(f"Unsupported command: {cmd}")
            if len(parts) != 2:
                raise ValueError(f"Invalid format for line: {line}")
            try:
                duration = float(parts[1])
            except ValueError:
                raise ValueError(f"Invalid duration in line: {line}")
            sequence.append({'type': cmd.upper(), 'duration': duration})
        return sequence

    def generate_edges(self, sequence: List[Dict]) -> List[Edge]:
        """Generate all edges from the pulse sequence using global leads/lags."""
        edges = []
        current_time = 0
        master_physical = self.channel_map[self.master_channel]  # e.g., CH0
        for instruction in sequence:
            cmd_type = instruction['type']
            duration = instruction['duration']
            if cmd_type == 'PULSE':
                # Master channel edges (always generated if master_channel is enabled)
                if self.master_channel in self.enabled_channels:
                    edges.append(Edge(current_time, master_physical, 1))
                    edges.append(Edge(current_time + duration, master_physical, 0))
                # Other channels' edges using global leads/lags
                for name, physical in self.channel_map.items():
                    if name != self.master_channel and name in self.enabled_channels:
                        lead = self.global_leads.get(name, 0)
                        lag = self.global_lags.get(name, 0)
                        edges.append(Edge(current_time - lead, physical, 1))  # Positive lead = earlier start
                        edges.append(Edge(current_time + duration + lag, physical, 0))
            elif cmd_type in ('DELAY', 'LONG_DELAY', 'WAIT'):
                edges.append(Edge(current_time + duration, None, 0))  # No channel changes
            current_time += duration
        return sorted(edges, key=lambda e: (e.time, e.channel or '', e.state))

    def merge_pulses(self, edges: List[Edge]) -> List[Edge]:
        """Merge pulses in the same channel if gaps are less than channel-specific connectivity."""
        merged = []
        i = 0
        while i < len(edges):
            edge = edges[i]
            merged.append(edge)
            if edge.state == 0 and edge.channel:  # Falling edge
                # Look for the next rising edge on the same channel
                j = i + 1
                next_rising = None
                while j < len(edges):
                    if edges[j].channel == edge.channel and edges[j].state == 1:
                        next_rising = edges[j]
                        break
                    j += 1
                if next_rising and next_rising.time - edge.time < self.connectivity.get(edge.channel, 100e-9):
                    merged.pop()  # Remove the falling edge
                    i = j  # Skip to the rising edge
                else:
                    i += 1
            else:
                i += 1
        return merged

    def generate_instructions(self, edges: List[Edge], sequence: List[Dict]) -> List[Instruction]:
        """Generate instructions from edges and sequence."""
        instructions = []
        addr = 1
        current_state = {ch: 0 for ch in self.channels}
        edge_index = 0
        sequence_index = 0

        while sequence_index < len(sequence):
            cmd_type = sequence[sequence_index]['type']
            duration = sequence[sequence_index]['duration']

            if cmd_type in ('PULSE', 'DELAY'):
                # Process edges within the current instruction's time window
                end_time = sum(seq['duration'] for seq in sequence[:sequence_index + 1])
                while edge_index < len(edges) and edges[edge_index].time <= end_time:
                    edge = edges[edge_index]
                    next_time = edges[edge_index + 1].time if edge_index + 1 < len(edges) else edge.time + self.clock_cycle
                    if next_time > end_time:
                        next_time = end_time
                    duration = self.quantize_time(next_time - edge.time)
                    if duration < self.clock_cycle:
                        duration = self.clock_cycle
                    if edge.channel:
                        current_state[edge.channel] = edge.state
                    pulse_bits = ''.join('1' if current_state[ch] else '0' for ch in reversed(self.channels))
                    instructions.append(Instruction(
                        addr=addr,
                        pulse_pattern=pulse_bits,
                        op_code='DELAY',
                        duration=duration
                    ))
                    addr += 1
                    edge_index += 1
                # If no edges were processed, add a delay instruction to cover the remaining time
                if edge_index == 0 or edges[edge_index - 1].time < end_time:
                    duration = self.quantize_time(end_time - (edges[edge_index - 1].time if edge_index > 0 else 0))
                    if duration >= self.clock_cycle:
                        pulse_bits = ''.join('1' if current_state[ch] else '0' for ch in reversed(self.channels))
                        instructions.append(Instruction(
                            addr=addr,
                            pulse_pattern=pulse_bits,
                            op_code='DELAY',
                            duration=duration
                        ))
                        addr += 1
            elif cmd_type == 'LONG_DELAY':
                pulse_bits = ''.join('0' for _ in self.channels)
                n = sequence[sequence_index].get('n', 1)
                instructions.append(Instruction(
                    addr=addr,
                    pulse_pattern=pulse_bits,
                    op_code='LONG_DELAY',
                    duration=duration,
                    data=n
                ))
                addr += 1
                edge_index += 1
            elif cmd_type == 'WAIT':
                pulse_bits = ''.join('0' for _ in self.channels)
                instructions.append(Instruction(
                    addr=addr,
                    pulse_pattern=pulse_bits,
                    op_code='WAIT',
                    duration=0
                ))
                addr += 1
                edge_index += 1
            sequence_index += 1

        # Add GOTO instruction
        pulse_bits = ''.join('0' for _ in self.channels)
        instructions.append(Instruction(
            addr=addr,
            pulse_pattern=pulse_bits,
            op_code='GOTO',
            duration=0,
            data=1  # Loop back to Addr 1
        ))
        return instructions

    def process_sequence(self, sequence: str) -> List[Instruction]:
        """Process a text-based sequence and generate instructions."""
        sequence_list = self.parse_sequence(sequence)
        edges = self.generate_edges(sequence_list)
        edges = self.merge_pulses(edges)
        return self.generate_instructions(edges, sequence_list)

    def convert_to_inst(self, pulse: int, data: int, op_code: int, delay: int) -> bytes:
        """Convert instruction fields to an 8-byte instruction word."""
        inst = (pulse << 56) + (data << 36) + (op_code << 32) + delay
        inst_bytes = inst.to_bytes(8, byteorder='big')
        print(f"Instruction bytes: {inst_bytes.hex()}")
        return inst_bytes

    def instructions_to_bytes(self, instructions: List[Instruction]) -> List[bytes]:
        """Convert instructions to 10-byte sequences for serial transmission."""
        result = []
        for inst in instructions:
            if inst.addr > 4095:
                raise ValueError(f"Address {inst.addr} must be less than 4096")
            
            # Convert pulse_pattern (string of 8 bits) to integer
            pulse = int(inst.pulse_pattern, 2)
            
            # Map op_code to numeric value
            op_code = self.op_code_map[inst.op_code]
            
            # Quantize delay to 4ns clock cycles (subtract 1 as per delay_inst)
            delay = int(round(inst.duration / self.clock_cycle - 1)) if inst.duration > 0 else 0
            print(f"Quantized delay: {delay} cycles (duration={inst.duration * 1e9:.0f} ns)")
            
            # Convert instruction to 8-byte word
            inst_bytes = self.convert_to_inst(pulse, inst.data, op_code, delay)
            
            # Prepend 2-byte address word with high bit set
            write_addr = ((1 << 12) + inst.addr).to_bytes(2, byteorder='big')
            print(f"Address bytes: {write_addr.hex()} (addr={inst.addr})")
            
            # Combine address and instruction
            result.append(write_addr + inst_bytes)
        
        return result

    def print_sequence(self, instructions: List[Instruction]):
        """Print the pulse sequence programmatically."""
        columns = [
            {'name': 'Addr', 'width': 7, 'value': lambda inst: str(inst.addr)},
            {'name': 'Type', 'width': 13, 'value': lambda inst: inst.op_code},
            *[
                {'name': f'CH{i}', 'width': 7, 'value': lambda inst, i=i: inst.pulse_pattern[7 - i]}
                for i in range(8)
            ]
        ]
        
        def get_param(inst):
            if inst.op_code == 'DELAY':
                return f"duration={inst.duration * 1e9:.0f} ns"
            elif inst.op_code == 'LONG_DELAY':
                return f"n={inst.data}, duration={inst.duration * 1e9:.0f} ns"
            elif inst.op_code == 'WAIT':
                return ""
            elif inst.op_code == 'GOTO':
                return f"target_addr={inst.data}"
            return ""

        header = ''.join(f"{col['name']:<{col['width']}}" for col in columns)
        print(header)

        for inst in instructions:
            row = ''.join(f"{col['value'](inst):<{col['width']}}" for col in columns)
            param = get_param(inst)
            print(row + param)

# Example usage
if __name__ == "__main__":
    # Define channel mapping: human-readable names to physical channels
    channel_map = {
        'MW': 'CH0',
        'AMP': 'CH1',
        'RX': 'CH2',
        'CH3': 'CH3',
        'CH4': 'CH4',
        'CH5': 'CH5',
        'CH6': 'CH6',
        'CH7': 'CH7'
    }
    # Define global lead and lag timings (positive lead = gate starts before MW)
    global_leads = {
        'MW': 0,
        'AMP': 200e-9,  # 20ns before MW
        'RX': 0,  # 10ns after MW
        'CH3': 0,     # Align with MW
        'CH4': 0,     # Align with MW
        'CH5': 0,     # Align with MW
        'CH6': 0,     # Align with MW
        'CH7': 0      # Align with MW
    }
    global_lags = {
        'MW': 0,
        'AMP': 10e-9,  # 15ns after MW
        'RX':  0,     # 5ns after MW
        'CH3': 0,       # Align with MW
        'CH4': 0,       # Align with MW
        'CH5': 0,       # Align with MW
        'CH6': 0,       # Align with MW
        'CH7': 0        # Align with MW
    }
    # Define channel-specific connectivity
    connectivity = {
        'CH0': 0,   # MW
        'CH1': 0,  # AMP (1000ns)
        'CH2': 0,   # RX
        'CH3': 0,
        'CH4': 0,   # TRIG
        'CH5': 0,
        'CH6': 0,
        'CH7': 0
    }
    # Define enabled channels
#    enabled_channels = {'MW', 'AMP', 'RX', 'CH4', 'CH5', 'CH6', 'CH7'}  # Enable TRIG
    enabled_channels = {'MW', 'AMP', 'RX', 'CH4'}  # Enable TRIG
#    enabled_channels = {'MW'}  # Enable TRIG
    # Example sequence
    sequence = """
    delay 100e-9
    pulse 100e-9
    delay 10e-3
    """
    generator = PulseSequenceGenerator(
        channel_map=channel_map,
        master_channel='MW',
        global_leads=global_leads,
        global_lags=global_lags,
        connectivity=connectivity,
        enabled_channels=enabled_channels
    )
    instructions = generator.process_sequence(sequence)
    generator.print_sequence(instructions)

    # Convert instructions to bytes for serial transmission
    byte_sequences = generator.instructions_to_bytes(instructions)
    print("-" * 50)
    print("Byte sequences for serial transmission:")
    for i, seq in enumerate(byte_sequences, 1):
        print(f"Instruction {i}: {seq.hex()}")

    # Troubleshooting: Print each instruction
    print("-" * 50)
    for inst in instructions:
        print(inst)

    try: #If FPGA Pulse Programmer connected, upload sequence
        import serial
        import time
        from serial.serialutil import SerialException
        ser = serial.Serial(port = 'COM7', baudrate = 115200, timeout = 1.)

        for this_byte in byte_sequences:
            time.sleep(0.01)
            ser.write(this_byte)
        ser.close()
    except SerialException as e:
        print(f"Error opening serial port: {e}")

