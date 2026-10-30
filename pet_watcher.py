#!/usr/bin/env python3
"""
Lightweight background watcher for Omarchy Bar Pet (bol.bar-pet).
Monitors keystrokes, typing rate, and CPU load with negligible resource usage.
Uses true kernel-level epoll blocking and zero-overhead C-state friendly waits.
Emits streaming JSON events to stdout for PetService.qml.
"""

import glob
import json
import os
import select
import struct
import sys
import time

def find_readable_keyboards():
    """Find readable evdev keyboard event devices, preferring dedicated keyboard symlinks."""
    paths = set(glob.glob("/dev/input/by-path/*-kbd") + glob.glob("/dev/input/by-id/*-kbd"))
    if not paths:
        # Fallback: inspect /proc/bus/input/devices for keyboard handlers
        try:
            with open("/proc/bus/input/devices", "r") as f:
                content = f.read()
            for section in content.split("\n\n"):
                if "Handlers=" in section and "kbd" in section and "mouse" not in section:
                    for line in section.splitlines():
                        if line.startswith("H: Handlers="):
                            for part in line.split():
                                if part.startswith("event"):
                                    paths.add(f"/dev/input/{part}")
        except Exception:
            pass
    if not paths:
        paths = set(glob.glob("/dev/input/event*"))

    readable = []
    for path in sorted(paths):
        try:
            fd = os.open(path, os.O_RDONLY | os.O_NONBLOCK)
            readable.append((path, fd))
        except (PermissionError, OSError):
            continue
    return readable

def read_irq_count():
    """Read total IRQ 1 (keyboard) interrupts from /proc/interrupts (fallback mode only)."""
    try:
        with open("/proc/interrupts", "r") as f:
            for line in f:
                parts = line.split()
                if parts and parts[0] == "1:":
                    return sum(int(p) for p in parts[1:] if p.isdigit())
    except Exception:
        pass
    return 0

def read_cpu_times():
    """Read idle and total CPU jiffies from /proc/stat."""
    try:
        with open("/proc/stat", "r") as f:
            for line in f:
                if line.startswith("cpu "):
                    parts = [int(p) for p in line.split()[1:]]
                    idle = parts[3] + parts[4]
                    total = sum(parts)
                    return idle, total
    except Exception:
        pass
    return 0, 0

def main():
    evdev_fds = find_readable_keyboards()
    has_evdev = len(evdev_fds) > 0

    last_irq = read_irq_count() if not has_evdev else 0
    last_idle, last_total = read_cpu_times()
    last_cpu_check = time.time()
    last_typed_emit = 0.0

    paw_toggle = False
    cpu_percent = 0
    cpu_interval = 3.0  # Measure CPU every 3.0s (saves wakeups)

    # Ensure unbuffered stdout
    sys.stdout.reconfigure(line_buffering=True)

    # Initial state greeting
    print(json.dumps({"ready": True, "mode": "evdev" if has_evdev else "interrupts", "cpu": 0}))

    epoll = None
    if has_evdev:
        epoll = select.epoll()
        for _, fd in evdev_fds:
            epoll.register(fd, select.EPOLLIN)

    try:
        while True:
            now = time.time()
            typed_now = False

            # 1. EVDEV mode: true kernel blocking via epoll (0% CPU when idle)
            if has_evdev and epoll:
                time_until_cpu = max(0.05, cpu_interval - (now - last_cpu_check))
                events = epoll.poll(timeout=time_until_cpu)
                for fd, event in events:
                    if event & select.EPOLLIN:
                        try:
                            while True:
                                data = os.read(fd, 24)
                                if len(data) < 24:
                                    break
                                # struct input_event: time_s, time_us, type, code, value
                                # type 1 is EV_KEY, value 1 is key press
                                _, _, ev_type, _, ev_val = struct.unpack("qqHHi", data)
                                if ev_type == 1 and ev_val == 1:
                                    typed_now = True
                        except (BlockingIOError, OSError):
                            pass
            else:
                # 2. IRQ fallback mode only when evdev permission is not available
                time.sleep(0.18)
                curr_irq = read_irq_count()
                if curr_irq > last_irq:
                    typed_now = True
                    last_irq = curr_irq
                elif curr_irq < last_irq:
                    last_irq = curr_irq

            now = time.time()

            # Emit typing event with slight debounce to avoid flooding IPC during fast typing
            if typed_now and (now - last_typed_emit >= 0.055):
                last_typed_emit = now
                paw_toggle = not paw_toggle
                paw = "l" if paw_toggle else "r"
                print(json.dumps({"typed": True, "paw": paw}))

            # 3. Check CPU usage every cpu_interval seconds
            if now - last_cpu_check >= cpu_interval:
                curr_idle, curr_total = read_cpu_times()
                delta_idle = curr_idle - last_idle
                delta_total = curr_total - last_total
                if delta_total > 0:
                    cpu_percent = int(max(0, min(100, (1.0 - (delta_idle / delta_total)) * 100)))
                last_idle = curr_idle
                last_total = curr_total
                last_cpu_check = now
                print(json.dumps({"cpu": cpu_percent}))

    except (KeyboardInterrupt, BrokenPipeError, IOError):
        pass
    finally:
        if epoll:
            epoll.close()
        for _, fd in evdev_fds:
            try:
                os.close(fd)
            except Exception:
                pass

if __name__ == "__main__":
    try:
        main()
    except (KeyboardInterrupt, BrokenPipeError):
        pass
