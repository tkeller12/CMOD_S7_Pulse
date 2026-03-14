import serial
import numpy as np
import time

# ────────────────────────────────────────────────
# Config
# ────────────────────────────────────────────────

PORT = "COM7"
BAUDRATE = 115200
CLOCK_PERIOD_S = 4e-9           # 250 MHz

# ────────────────────────────────────────────────
# Helpers
# ────────────────────────────────────────────────

def seconds_to_ticks(time_s: float) -> int:
    return int(round(time_s / CLOCK_PERIOD_S))


def build_instruction(
    pulse: int = 0,
    data: int = 0,
    op_code: int = 0,
    delay_ticks: int = 0
) -> bytes:
    if not (0 <= delay_ticks <= 0xFFFFFFFF):
        raise ValueError(f"delay_ticks out of range: {delay_ticks}")
    inst = (
        (pulse      << 56) |
        (data       << 36) |
        (op_code    << 32) |
        delay_ticks
    )
    return inst.to_bytes(8, byteorder="big")


def instr_delay(addr: int, pulse: int, delay_s: float) -> bytes:
    ticks = max(0, seconds_to_ticks(delay_s) - 1)
    inst = build_instruction(pulse=pulse, op_code=1, delay_ticks=ticks)
    addr_bytes = ((1 << 12) + addr).to_bytes(2, "big")
    return addr_bytes + inst


# ────────────────────────────────────────────────
# Example usage
# ────────────────────────────────────────────────

def main():
    sequence = []

    # Some example delays in seconds
    times_to_test = [
        0,          # 0 ns
        4e-9,       # 4 ns  → should become ticks=0 or 1 depending on rounding
        8e-9,       # 8 ns
        200e-9,     # 200 ns
        12e-6,      # 12 µs
        5e-3,       # 5 ms
    ]

    addr = 0
    for t in times_to_test:
        packet = instr_delay(addr, pulse=0xAA, delay_s=t)
        print(f"Addr {addr:3d} | {t*1e9:8.1f} ns → packet: {packet.hex()}")
        sequence.append(packet)
        addr += 1

    # Optional: write to serial
    with serial.Serial(PORT, BAUDRATE, timeout=1) as ser:
        for packet in sequence:
            ser.write(packet)
            time.sleep(0.002)  # small breathing room

    print("\nDone.")


if __name__ == "__main__":
    main()
