import serial
import numpy as np
import time

#ser = serial.Serial(port = 'COM7', baudrate = 115200, timeout = 1.)

pulse = 0b0001111
data = 1024
op_code = 1
delay = 6
def convert_to_inst(pulse, data, op_code, delay):
    inst = (pulse << 56) + (data << 36) + (op_code << 32) + delay
    inst_bytes = inst.to_bytes(8, byteorder = 'big')
    print(inst_bytes.hex())
    return inst_bytes

inst = convert_to_inst(pulse, data, op_code, delay)
print(inst)

def delay_inst(pulse, delay):
    int_delay = int(np.round(delay / 4e-9 - 1))
    inst = convert_to_inst(pulse, 0, 1, int_delay)
    print(int_delay)
    return inst

inst1 = delay_inst(pulse, 16e-9)
inst2 = delay_inst(pulse, 32e-9)
