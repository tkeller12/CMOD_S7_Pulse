import pypulsegen as pg

pulse_program = '''
delay 4000e-9
pulse 12e-9
'''

config = pg.load_config_from_json('config.json')
config.rep_time = 10e-6-12e-9
config.inverted_channels = ['CH3']
#config.inverted_channels = []

inst_bytes = pg.compile_pulse_program(pulse_program, config)

print('-'*89)
print('INSTRUCTION BYTES')
print('-'*89)
print('COM||ADD R------| |PULSE-| |DATA--- -------- ---||OP| |DELAY->')
for inst in inst_bytes:
    binary_string = ' '.join(f"{byte:08b}" for byte in inst)
    print(binary_string)

pg.stop()
pg.upload_sequence(inst_bytes)
pg.start()
#pg.stop()
