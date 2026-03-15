import serial
import numpy as np
import time

#ser = serial.Serial(port = 'COM7', baudrate = 115200, timeout = 1.)
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
#print(inst)

def delay_inst(pulse, delay):
    int_delay = int(np.round(delay / 8e-9 - 1))
    inst = convert_to_inst(pulse, 0, 1, int_delay)
#    print(int_delay)
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

    int_delay = int(np.round(delay / 8e-9 - 1))
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


p0 = 8e-9
d0 = 8e-9

write_all = False

if write_all:
    max_addr = 4095
else:
    max_addr = 10
ix2 = 0
print('COM||ADD R------| |PULSE-| |DATA--- -------- ---||OP| |DELAY->')

for ix in range(max_addr):
#    print('index:', ix)
    ix2+=1

    if ix % 2 == 0:
        write_inst = delay(ix,0b01010101,p0)
    else:
        write_inst = delay(ix,0b10101010,d0)

    binary_string = ' '.join(f"{byte:08b}" for byte in write_inst)
    print(binary_string)

    ser.write(write_inst)

#write_inst = delay(ix2,0xff,1000e-9)
write_inst = delay(ix2,0x00,1000e-9)
binary_string = ' '.join(f"{byte:08b}" for byte in write_inst)
print(binary_string)
ser.write(write_inst)
write_inst = goto(ix2+2, 0)
#write_inst = delay(ix2+1,0x00,1000e-9)
binary_string = ' '.join(f"{byte:08b}" for byte in write_inst)
print(binary_string)
ser.write(write_inst)
#write_inst2 = delay(1,0x55,.2)
#write_inst3 = delay(3,0xaa,10e-9)
#print(write_inst)
#print(write_inst.hex())

#ser.write(write_inst1)
#ser.write(write_inst2)
#ser.write(write_inst3)
ser.close()

