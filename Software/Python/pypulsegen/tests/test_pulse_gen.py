import unittest
from pypulsegen.core import parse_pulse_program

class TestPyPulseGen(unittest.TestCase):
    def test_parse_pulse_program(self):
        program = "delay 1e-6\npulse 100e-9"
        commands = parse_pulse_program(program)
        self.assertEqual(len(commands), 2)
        self.assertEqual(commands[0].name, "DELAY")
        self.assertEqual(commands[0].duration, 1e-6)
