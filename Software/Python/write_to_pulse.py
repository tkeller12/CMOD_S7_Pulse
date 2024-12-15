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
    print(inst_bytes.hex())
    return inst_bytes

inst = convert_to_inst(pulse, data, op_code, delay)
print(inst)

def delay_inst(pulse, delay):
    int_delay = int(np.round(delay / 4e-9 - 1))
    inst = convert_to_inst(pulse, 0, 1, int_delay)
    print(int_delay)
    return inst

def delay(addr, pulse, delay):
    inst = delay_inst(pulse, delay)
    addr = addr.to_bytes(1, byteorder = 'big')
    write = (1).to_bytes(1, byteorder = 'big')

    return write + addr + inst


#delay_s = 100e-9
#for ix in range(255):
#    if ix % 2 == 0:
#        write_inst1 = delay(ix,0xaa,delay_s)
#    else:
#        write_inst1 = delay(ix,0x55,delay_s)
#    ser.write(write_inst1)

p90 = 40e-9
p180 = 80e-9
pdelay = 200e-9
reptime = 200e-6

for ix in range(255):
    if ix == 1:
        write_inst = delay(ix,0xff,p90)
    elif ix == 2:
        write_inst = delay(ix,0x00,pdelay)
    elif ix == 3:
        write_inst = delay(ix,0xff,p180)
    elif ix == 4:
        write_inst = delay(ix,0x00,reptime)
    else:
        write_inst = delay(ix,0,10e-9)

    ser.write(write_inst)

#write_inst2 = delay(1,0x55,.2)
#write_inst3 = delay(3,0xaa,10e-9)
#print(write_inst)
#print(write_inst.hex())

#ser.write(write_inst1)
#ser.write(write_inst2)
#ser.write(write_inst3)
ser.close()

