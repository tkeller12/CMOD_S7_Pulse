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
    if addr > 4095:
        raise ValueError('Address must be less than 4096')

    write_addr = ((1<<12) + addr).to_bytes(2, byteorder = 'big')
    return write_addr + inst

def long_delay(addr, pulse, n, delay):
    '''NEEDS WORK
    '''
    inst = delay_inst(pulse, delay)
    if addr > 4095:
        raise ValueError('Address must be less than 4096')
    if n > 4096:
        raise ValueError('n must be less than 4096')

    int_delay = int(np.round(delay / 4e-9 - 1))
    inst = convert_to_inst(pulse, n, 2, int_delay)
    write_addr = ((1<<12) + addr).to_bytes(2, byteorder = 'big')
    return write_addr + inst

def wait(addr):
    inst = convert_to_inst(0, 0, 4, 0)
    write_addr = ((1<<12) + addr).to_bytes(2, byteorder = 'big')
    return write_addr + inst

def goto(addr, goto_addr):
    if (addr > 4095) or (goto_addr > 4095):
        raise ValueError('Address must be less than 4096')
    inst = convert_to_inst(0, goto_addr, 3, 0)
    write_addr = ((1<<12) + addr).to_bytes(2, byteorder = 'big')
    return write_addr + inst


#delay_s = 100e-9
#for ix in range(255):
#    if ix % 2 == 0:
#        write_inst1 = delay(ix,0xaa,delay_s)
#    else:
#        write_inst1 = delay(ix,0x55,delay_s)
#    ser.write(write_inst1)

p90 = 16e-9
p180 = 32e-9
pdelay = 200e-9
reptime = 100e-6
reptime_long = 0.1

for ix in range(4095):
    if ix == 1:
        write_inst = delay(ix,0xff,p90)
    elif ix == 2:
        write_inst = delay(ix,0x00,pdelay)
    elif ix == 3:
        write_inst = delay(ix,0xff,p180)
    elif ix == 4:
        write_inst = delay(ix,0x00,reptime)
#        write_inst = long_delay(ix,0x00, 1,reptime)
#    elif ix == 5:
#        write_inst = wait(ix)
    elif ix == 5:
        write_inst = goto(ix, 1)
    elif ix == 6:
        write_inst = delay(ix,0x00,reptime_long)
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

