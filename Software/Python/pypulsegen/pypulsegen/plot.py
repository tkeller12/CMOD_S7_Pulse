from typing import List, Optional
import matplotlib.pyplot as plt
from pypulsegen.types import Config, Instruction

def plot_pulse_sequence(instructions: List[Instruction], config: Config, save_path: Optional[str] = None) -> None:
    """
    Plot the pulse sequence for each active channel using Matplotlib, based on Instruction objects.

    Args:
        instructions: List of Instruction objects with addr, pulse_pattern (int), data, op_code, and delay.
        config: Config object with channel settings, aliases, and resolution.
        save_path: Optional file path to save the plot (e.g., 'pulse_sequence.png').

    Raises:
        ImportError: If Matplotlib is not installed.
        ValueError: If instructions or config.active_channels is empty.
    """
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        raise ImportError("Matplotlib is required for plotting. Install it with `pip install matplotlib`.")

    if not instructions:
        raise ValueError("No instructions provided to plot.")
    if not config.active_channels:
        raise ValueError("No active channels specified in config.")

    # Build timeline for each channel using raw instruction data
    channel_edges = {channel: [(0.0, 0)] for channel in config.active_channels}  # Start at t=0, state=0
    current_time = 0.0  # Time in seconds

    for instruction in instructions:
        if instruction.op_code not in {1, 2}:  # Only handle DELAY (1) and PULSE (2)
            continue

        # Calculate duration in seconds
        duration = instruction.delay * config.resolution

        # Extract channel states from pulse_pattern (int)
        pulse_bits = instruction.pulse_pattern

        # Add edges for each active channel
        for channel in config.active_channels:
            channel_idx = config.channels.index(channel)
            state = 1 if pulse_bits & (1 << channel_idx) else 0
            channel_edges[channel].append((current_time, state))

        current_time += duration

    # Create figure with one subplot per active channel
    fig, axes = plt.subplots(
        len(config.active_channels), 1, sharex=True,
        figsize=(10, 2 * len(config.active_channels))
    )
    if len(config.active_channels) == 1:
        axes = [axes]  # Ensure axes is iterable for single channel

    # Plot each channel
    for ax, channel in zip(axes, config.active_channels):
        # Sort edges by time and build step function data
        edges = sorted(channel_edges[channel], key=lambda x: x[0])
        if not edges:
            continue

        times_ns = [edge[0] * 1e9 for edge in edges]  # Convert to nanoseconds
        states = [edge[1] for edge in edges]
        times_ns.append(current_time * 1e9)  # Extend to end of sequence
        states.append(states[-1])  # Hold last state

        # Plot step function
        ax.step(times_ns, states, where='post', color='blue')
        ax.set_ylim(-0.1, 1.1)
        ax.set_yticks([0, 1])
        ax.set_yticklabels(['Low', 'High'])
        ax.grid(True, which='major', axis='x')
        ax.set_ylabel(config.alias.get(channel, channel))
        ax.set_title(f"Pulse Sequence for {config.alias.get(channel, channel)}")

    # Set x-axis label and limits
    axes[-1].set_xlabel("Time (ns)")
    axes[-1].set_xlim(0, current_time * 1e9)

    # Adjust layout and display
    plt.tight_layout()
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.show()