#import sys
#sys.path.append('..')
#from pypulsegen.types import Config
import pypulsegen as pg

pulse_program = '''
delay 1000e-9
pulse 100e-9
delay 400e-9
pulse 200e-9
delay 10e-6
'''

config = pg.load_config_from_json('config.json')
print(config)
