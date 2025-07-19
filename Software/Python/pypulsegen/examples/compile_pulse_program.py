#import sys
#sys.path.append('..')
#from pypulsegen.types import Config
import pypulsegen as pg

pulse_program = '''
delay 1000e-9
pulse 40e-9
delay 500e-9
pulse 80e-9
'''

config = pg.load_config_from_json('config.json')
#print(config)
config.rep_time = 0.1

inst_bytes = pg.compile_pulse_program(pulse_program, config)
#inst_bytes = pg.core.compile_pulse_program(pulse_program, config)

#print(inst_bytes)


print('-'*50)
print('INSTRUCTION BYTES')
print('-'*50)
for inst in inst_bytes:
#        print(f'{inst:0{8}b}')
    binary_string = ' '.join(f"{byte:08b}" for byte in inst)
    print(binary_string)


try: #If FPGA Pulse Programmer connected, upload sequence
    import serial
    import time
    from serial.serialutil import SerialException
    ser = serial.Serial(port = 'COM7', baudrate = 115200, timeout = 1.)

    for this_byte in inst_bytes:
        print('UPLOADING BYTE:', this_byte)
        ser.write(this_byte)
    ser.close()
except SerialException as e:
    print(f"Error opening serial port: {e}")
