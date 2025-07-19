from dataclasses import dataclass

@dataclass
class Edge:
    time: float
    channel: str
    state: int # 1 for rising, 0 for falling

@dataclass
class Instruction: # 80-bit programming word of FPGA
    addr: int
    pulse_pattern: str
    data: int # used for goto, long_delay, etc.
    op_code: int # e.g., NOOP, DELAY, LONG_DELAY, GOTO, WAIT
    delay: int # clock cycles to delay (0 -> 1 clock cycle)

@dataclass
class Command:
    name: str # e.g., NOOP, DELAY, GOTO, WAIT, LONG_DELAY
    duration: float
    data: int = 0 # used for goto, long_delay, etc.
