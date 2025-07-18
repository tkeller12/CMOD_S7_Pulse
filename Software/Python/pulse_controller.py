import serial
import numpy as np
from dataclasses import dataclass
from typing import Union

class PulseController:
    """Controller for generating and sending pulse instructions to a serial device."""
    
    # Constants
    MAX_ADDRESS = 4095
    MAX_N_VALUE = 4096
    TIME_STEP = 4e-9  # Time step in seconds
    
    @dataclass
    class InstructionConfig:
        """Configuration for pulse instructions."""
        pulse: int
        data: int
        op_code: int
        delay: Union[float, int]

    def __init__(self, port: str = 'COM7', baudrate: int = 115200, timeout: float = 1.0):
        """Initialize serial connection."""
        try:
            self.serial = serial.Serial(port=port, baudrate=baudrate, timeout=timeout)
        except serial.SerialException as e:
            raise ConnectionError(f"Failed to connect to serial port {port}: {str(e)}")

    def convert_to_instruction(self, config: InstructionConfig) -> bytes:
        """Convert instruction parameters to byte format."""
        if not isinstance(config.delay, int):
            delay = int(np.round(config.delay / self.TIME_STEP - 1))
        else:
            delay = config.delay
            
        instruction = (config.pulse << 56) + (config.data << 36) + (config.op_code << 32) + delay
        return instruction.to_bytes(8, byteorder='big')

    def create_delay_instruction(self, pulse: int, delay: float) -> bytes:
        """Create a delay instruction with specified pulse and delay time."""
        config = self.InstructionConfig(pulse=pulse, data=0, op_code=1, delay=delay)
        return self.convert_to_instruction(config)

    def create_addressed_instruction(self, addr: int, instruction: bytes) -> bytes:
        """Add address to instruction bytes."""
        if addr > self.MAX_ADDRESS:
            raise ValueError(f'Address must be less than or equal to {self.MAX_ADDRESS}')
        write_addr = ((1 << 12) + addr).to_bytes(2, byteorder='big')
        return write_addr + instruction

    def delay(self, addr: int, pulse: int, delay: float) -> bytes:
        """Create a delay instruction with address."""
        instruction = self.create_delay_instruction(pulse, delay)
        return self.create_addressed_instruction(addr, instruction)

    def long_delay(self, addr: int, pulse: int, n: int, delay: float) -> bytes:
        """Create a long delay instruction with address."""
        if addr > self.MAX_ADDRESS:
            raise ValueError(f'Address must be less than or equal to {self.MAX_ADDRESS}')
        if n > self.MAX_N_VALUE:
            raise ValueError(f'n must be less than or equal to {self.MAX_N_VALUE}')
        
        config = self.InstructionConfig(pulse=pulse, data=n, op_code=2, delay=delay)
        instruction = self.convert_to_instruction(config)
        return self.create_addressed_instruction(addr, instruction)

    def wait(self, addr: int) -> bytes:
        """Create a wait instruction with address."""
        config = self.InstructionConfig(pulse=0, data=0, op_code=4, delay=0)
        instruction = self.convert_to_instruction(config)
        return self.create_addressed_instruction(addr, instruction)

    def goto(self, addr: int, goto_addr: int) -> bytes:
        """Create a goto instruction with address."""
        if addr > self.MAX_ADDRESS or goto_addr > self.MAX_ADDRESS:
            raise ValueError(f'Both address and goto address must be less than or equal to {self.MAX_ADDRESS}')
        config = self.InstructionConfig(pulse=0, data=goto_addr, op_code=3, delay=0)
        instruction = self.convert_to_instruction(config)
        return self.create_addressed_instruction(addr, instruction)

    def close(self):
        """Close the serial connection."""
        if hasattr(self, 'serial') and self.serial.is_open:
            self.serial.close()

def main():
    """Main function to demonstrate pulse controller usage."""
    # Configuration parameters
    p90 = 100e-9  # 90-degree pulse duration
    p180 = 200e-9  # 180-degree pulse duration
    pdelay = 200e-9  # Pulse delay
    reptime = 10e-3  # Repetition time
    write_all = False  # Control whether to write all addresses
    
    controller = PulseController()
    
    try:
        max_addr = 4095 if write_all else 100
        
        for addr in range(max_addr):
            print(f'Processing address: {addr}')
            
            # Alternate between pulse patterns
            pulse = 0b00010000 if addr % 2 == 0 else 0
            instruction = controller.delay(addr, pulse, p90)
            
            print(f'Instruction (hex): {instruction.hex()}')
            controller.serial.write(instruction)
            
    except Exception as e:
        print(f"Error during execution: {str(e)}")
    finally:
        controller.close()

if __name__ == "__main__":
    main()
