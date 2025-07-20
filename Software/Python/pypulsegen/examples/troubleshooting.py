import pypulsegen as pg
import time

pulse_program = '''
delay 1000e-9
pulse 8e-9
delay 200e-9
pulse 16e-9
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

print('-'*50)
print('INSTRUCTION')
print('-'*50)
for inst in instructions:
    print(inst)
    if (inst.delay == 0) and (inst.op_code == 1):
        raise ValueError('delay instruction has delay of 0, currently not supported by FPGA')



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

pg.plot_pulse_sequence(instructions, config)
