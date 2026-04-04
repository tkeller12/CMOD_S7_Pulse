import serial
import time
from serial.serialutil import SerialException
from serial.tools import list_ports

# Serial port configuration
#SERIAL_PORT = 'COM7'  # Default COM port, can be changed by user
SERIAL_PORT = None    # Default COM port, can be changed by user
# BAUDRATE = 115200     # Fixed baudrate
BAUDRATE = 1000000     # Fixed baudrate
TIMEOUT = 1.0         # Fixed timeout in seconds
VID = 1027
PID = 24592

def auto_detect_port() -> str:
    """
    Detect the serial port for the FPGA based on VID:1027 and PID:24592.

    Returns:
        str: Detected port name (e.g., 'COM3', '/dev/ttyUSB0').

    Raises:
        RuntimeError: If no matching port is found.
    """
    ports = list_ports.comports()
    for port in ports:
        if port.vid == VID and port.pid == PID:
            return port.device
    raise RuntimeError("No serial port found with VID:1027 and PID:24592")


def set_serial_port(port: str = None) -> None:
    """
    Set the serial port for FPGA communication.

    Args:
        port: Serial port name (e.g., 'COM3', '/dev/ttyUSB0').

    Raises:
        ValueError: If port is not a string.
    """
    global SERIAL_PORT
    if port is None:
        SERIAL_PORT = auto_detect_port()
    elif not isinstance(port, str):
        raise ValueError(f"Invalid serial port: {port} (must be a string or None)")
    else:
        SERIAL_PORT = port

try:
    SERIAL_PORT = auto_detect_port()
#    set_serial_port(SERIAL_PORT)
except RuntimeError:
    pass

def inst_command(command):
    return (command<<76).to_bytes(10, byteorder = 'big')

def start():
    ser = serial.Serial(port = SERIAL_PORT, baudrate = BAUDRATE, timeout = TIMEOUT)
    inst_word = inst_command(2)
    ser.write(inst_word)
    ser.close()

def stop():
    inst_word = inst_command(3)
    ser = serial.Serial(port = SERIAL_PORT, baudrate = BAUDRATE, timeout = TIMEOUT)
    ser.write(inst_word)
    ser.close()

def upload_sequence(inst_bytes: list):#, hw_config)
    try: #If FPGA Pulse Programmer connected, upload sequence
        ser = serial.Serial(port = SERIAL_PORT, baudrate = BAUDRATE, timeout = TIMEOUT)
#        print('UPLOADING SEQUENCE...')
        for this_byte in inst_bytes:
#            print('UPLOADING BYTE:', this_byte)
            ser.write(this_byte)
        ser.close()
#        print('DONE UPLOADING SEQUENCE')
    except SerialException as e:
        print(f"Error opening serial port: {e}")
