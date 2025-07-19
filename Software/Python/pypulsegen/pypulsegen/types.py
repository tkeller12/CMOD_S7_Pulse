from dataclasses import dataclass
from typing import List, Dict
import json

@dataclass
class Edge:
    time: float
    channel: str
    state: int # 1 for rising, 0 for falling

@dataclass
class Instruction: # 80-bit programming word of FPGA
    addr: int
    pulse_pattern: int
    data: int # used for goto, long_delay, etc.
    op_code: int # e.g., NOOP, DELAY, LONG_DELAY, GOTO, WAIT
    delay: int # clock cycles to delay (0 -> 1 clock cycle)

@dataclass
class Command:
    name: str # e.g., NOOP, DELAY, GOTO, WAIT, LONG_DELAY
    duration: float
    data: int = 0 # used for goto, long_delay, etc.

@dataclass
class Config:
    leads: Dict[str, float]  # Lead times per channel (seconds)
    lags: Dict[str, float]   # Lag times per channel (seconds)
    connectivity: Dict[str, float]  # Minimum time between pulses per channel
    active_channels: List[str]     # List of active channels
    inverted_channels: List[str]   # List of inverted channels
    rep_time: float               # Repetition time (seconds)
    alias: Dict[str, str]         # Channel aliases for display
    resolution: float = 8e-9      # Pulse programmer time resolution
    channels: List[str] = None    # Available channels
    start_addr: int = 1           # Starting address for instructions

    def __post_init__(self):
        # Initialize default channels if not provided
        if self.channels is None:
            self.channels = [f'CH{ix}' for ix in range(8)]
        # Validate inputs
        for channel in self.active_channels:
            if channel not in self.channels:
                raise ValueError(f"Invalid active channel: {channel}")
        for channel in self.inverted_channels:
            if channel not in self.channels:
                raise ValueError(f"Invalid inverted channel: {channel}")
        for channel in self.leads:
            if channel not in self.channels:
                raise ValueError(f"Invalid channel in leads: {channel}")
            if self.leads[channel] < 0:
                raise ValueError(f"Negative lead time for {channel}")
        for channel in self.lags:
            if channel not in self.channels:
                raise ValueError(f"Invalid channel in lags: {channel}")
        for channel in self.connectivity:
            if channel not in self.channels:
                raise ValueError(f"Invalid channel in connectivity: {channel}")
            if self.connectivity[channel] < 0:
                raise ValueError(f"Negative connectivity time for {channel}")
        if self.rep_time <= 0:
            raise ValueError("Repetition time must be positive")

    def __repr__(self) -> str:
        """
        Return a human-readable string representation of the Config object, with attributes displayed line by line.

        Returns:
            str: Formatted string with each attribute and its values.
        """
        lines = ["Config:"]

        # Format dictionary attributes
        for attr, label in [
            (self.leads, "leads"),
            (self.lags, "lags"),
            (self.connectivity, "connectivity")
        ]:
            lines.append(f"  {label}:")
            for channel, value in sorted(attr.items()):
                lines.append(f"    {channel}: {value * 1e9:.1f} ns")

        # Format list attributes
        lines.append(f"  active_channels: {', '.join(self.active_channels) if self.active_channels else '[]'}")
        lines.append(f"  inverted_channels: {', '.join(self.inverted_channels) if self.inverted_channels else '[]'}")

        # Format rep_time
        lines.append(f"  rep_time: {self.rep_time * 1e9:.1f} ns")

        # Format alias dictionary
        lines.append("  alias:")
        for channel, alias in sorted(self.alias.items()):
            lines.append(f"    {channel}: {alias}")
        if not self.alias:
            lines.append("    {}")

        # Format remaining attributes
        lines.append(f"  resolution: {self.resolution * 1e9:.1f} ns")
        lines.append(f"  channels: {', '.join(self.channels) if self.channels else '[]'}")
        lines.append(f"  start_addr: {self.start_addr}")

        return "\n".join(lines)
