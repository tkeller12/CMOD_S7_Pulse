import serial
import time
from serial.serialutil import SerialException

try: #If FPGA Pulse Programmer connected, upload sequence
    ser = serial.Serial(port = 'COM7', baudrate = 115200, timeout = 1.)
    print('UPLOADING SEQUENCE...')
    for this_byte in inst_bytes:
        print('UPLOADING BYTE:', this_byte)
        ser.write(this_byte)
    ser.close()
    print('DONE UPLOADING SEQUENCE')
except SerialException as e:
    print(f"Error opening serial port: {e}")
