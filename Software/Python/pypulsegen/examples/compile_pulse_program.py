import pypulsegen as pg

pulse_program = '''
delay 1000e-9
pulse 40e-9
delay 600e-9
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
    binary_string = ' '.join(f"{byte:08b}" for byte in inst)
    print(binary_string)

pg.stop()
pg.upload_sequence(inst_bytes)
pg.start()

