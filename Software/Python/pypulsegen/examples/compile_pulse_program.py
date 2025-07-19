import pypulsegen as pg

pulse_program = '''
delay 1000e-9
pulse 40e-9
delay 600e-9
pulse 80e-9
'''

config = pg.load_config_from_json('config.json')
config.rep_time = 0.1
config.start_addr = 1
#print('-'*50)
#print('CONFIG')
#print('-'*50)
#print(config)

commands = pg.core.parse_pulse_program(pulse_program)
master_edges = pg.core.locate_master_edges(commands)
edges = pg.core.locate_edges(master_edges, config)
updated_edges = pg.core.merge_edges_connectivity(edges, config)
sorted_edges = pg.core.sort_edges(updated_edges)
all_states = pg.core.compile_states(sorted_edges, config)
instructions = pg.core.generate_instructions(all_states, config)
inst_bytes = pg.core.instructions_to_bytes(instructions)

pg.plot_pulse_sequence(instructions, config)

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

