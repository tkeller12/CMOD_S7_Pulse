import serial
import numpy as np
import time

ser = serial.Serial(port = 'COM7', baudrate = 115200, timeout = 1.)

pulse = 0b0001111
data = 1024
op_code = 1
delay = 6

def convert_to_inst(pulse, data, op_code, delay):
    inst = (pulse << 56) + (data << 36) + (op_code << 32) + delay
    inst_bytes = inst.to_bytes(8, byteorder = 'big')
#    print(inst_bytes.hex())
    return inst_bytes

inst = convert_to_inst(pulse, data, op_code, delay)
print(inst)

def delay_inst(pulse, delay):
    int_delay = int(np.round(delay / 4e-9 - 1))
    inst = convert_to_inst(pulse, 0, 1, int_delay)
#    print(int_delay)
    return inst

def delay(addr, pulse, delay):
    inst = delay_inst(pulse, delay)
    if addr > 4095:
        raise ValueError('Address must be less than 4096')
#    addr = addr.to_bytes(2, byteorder = 'big')
#    write = (1).to_bytes(1, byteorder = 'big')

    write_addr = ((1<<12) + addr).to_bytes(2, byteorder = 'big')
    return write_addr + inst


# why does address 0 not work? is it a python code issue?
#

#import re
#
#def hexify(s):
#    return "b'" + re.sub(r'.', lambda m: f'\\x{ord(m.group(0)):02x}', buf.decode('latin1')) + "'"
#
#buf = b'\x00\xdd\x41'
#print(hexify(buf))

for ix in range(8):
    print(bin(0xff - 2**ix))
    pulse = 0xff - 2**ix
    write_inst = delay(ix+1, pulse, 0.1)
    print(write_inst)
    ser.write(write_inst)

ser.close()

