import serial
import time
from serial.serialutil import SerialException

def inst_command(command):
    return (command<<76).to_bytes(10, byteorder = 'big')

def start():
    ser = serial.Serial(port = 'COM7', baudrate = 115200, timeout = 1.)
    inst_word = inst_command(2)
    ser.write(inst_word)
    ser.close()


def stop():
    inst_word = inst_command(3)

    ser = serial.Serial(port = 'COM7', baudrate = 115200, timeout = 1.)
    ser.write(inst_word)
    ser.close()

def upload_sequence(inst_bytes: list):#, hw_config)
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
