import serial
import numpy as np
import time

#ser = serial.Serial(port = 'COM7', baudrate = 115200, timeout = 1.)
ser = serial.Serial(port = 'COM4', baudrate = 115200, timeout = 1.)

def convert_to_inst(pulse, data, op_code, delay):
    inst = (pulse << 56) + (data << 36) + (op_code << 32) + delay
    inst_bytes = inst.to_bytes(8, byteorder = 'big')
    return inst_bytes


def start():
    inst = (0).to_bytes(8, byteorder = 'big')
    write_addr = ((2<<12)).to_bytes(2, byteorder = 'big')
    return write_addr + inst

def stop():
    inst = (0).to_bytes(8, byteorder = 'big')
    write_addr = ((3<<12)).to_bytes(2, byteorder = 'big')
    return write_addr + inst

def delay_inst(pulse, delay):
    int_delay = int(np.round(delay / 4e-9 - 1))
    inst = convert_to_inst(pulse, 0, 1, int_delay)
    return inst

def delay(addr, pulse, delay):
    inst = delay_inst(pulse, delay)
    if addr > 4095:
        raise ValueError('Address must be less than 4096')

    write_addr = ((1<<12) + addr).to_bytes(2, byteorder = 'big')
    return write_addr + inst


for ix in range(256):
#    print('-'*50)
#    print(ix)
#    print(bin(0xff - 2**ix))
#    pulse = 0xff - 2**ix
#    pulse = 2**ix

#    pulse = ~(2**ix) & 0xff # most correct
    pulse = 2**ix
#    pulse = 0xff
    pulse = 0x00

#    print(bin(pulse))
    print(format(pulse, '08b'))
#    print(pulse)
#    print(pulse.to_bytes(1,byteorder = 'big'))
    write_inst = delay(ix, ix, 0.1)
#    print(write_inst)
    ser.write(write_inst)

#ser.close()

