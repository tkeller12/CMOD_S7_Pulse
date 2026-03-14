import pypulsegen as pg

pulse_program = '''
delay 5000e-9
pulse 200e-9
delay 800e-9
pulse 200e-9
'''

config = pg.load_config_from_json('config.json')
config.rep_time = 1e-3
config.inverted_channels = ['CH3']
#config.inverted_channels = []

inst_bytes = pg.compile_pulse_program(pulse_program, config)

print('-'*50)
print('INSTRUCTION BYTES')
print('-'*50)
for inst in inst_bytes:
    binary_string = ' '.join(f"{byte:08b}" for byte in inst)
    print(binary_string)

pg.stop()
pg.upload_sequence(inst_bytes)
pg.start()
pg.stop()
