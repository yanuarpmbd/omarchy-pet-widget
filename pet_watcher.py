#!/usr/bin/env python3
"""
Lightweight background watcher for Omarchy Bar Pet (bol.bar-pet).
Monitors keystrokes, typing rate, and CPU load with negligible resource usage.
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
    """Find any readable evdev keyboard event devices."""
    readable = []
    # Check by-id first for clear keyboard markers
    candidates = glob.glob("/dev/input/by-id/*-kbd") or glob.glob("/dev/input/event*")
    for path in candidates:
        try:
            fd = os.open(path, os.O_RDONLY | os.O_NONBLOCK)
            readable.append((path, fd))
        except (PermissionError, OSError):
            continue
    return readable

def read_irq_count():
    """Read total IRQ 1 (keyboard) interrupts from /proc/interrupts."""
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

    last_irq = read_irq_count()
    last_idle, last_total = read_cpu_times()
    last_cpu_check = time.time()
    last_heartbeat = time.time()

    paw_toggle = False
    cpu_percent = 0

    # Ensure unbuffered stdout
    sys.stdout.reconfigure(line_buffering=True)

    # Initial state greeting
    print(json.dumps({"ready": True, "mode": "evdev" if has_evdev else "interrupts", "cpu": 0}))

    epoll = None
    fd_to_path = {}
    if has_evdev:
        epoll = select.epoll()
        for path, fd in evdev_fds:
            epoll.register(fd, select.EPOLLIN)
            fd_to_path[fd] = path

    try:
        while True:
            now = time.time()
            typed_now = False

            # 1. Check EVDEV if available
            if has_evdev and epoll:
                events = epoll.poll(timeout=0.1)
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

            # 2. Check IRQ interrupts fallback
            if not typed_now:
                curr_irq = read_irq_count()
                if curr_irq > last_irq:
                    typed_now = True
                    last_irq = curr_irq
                elif curr_irq < last_irq: # Counter reset
                    last_irq = curr_irq

            # If typing detected, emit event
            if typed_now:
                paw_toggle = not paw_toggle
                paw = "l" if paw_toggle else "r"
                print(json.dumps({"typed": True, "paw": paw}))

            # 3. Check CPU usage every 1.5 seconds
            if now - last_cpu_check >= 1.5:
                curr_idle, curr_total = read_cpu_times()
                delta_idle = curr_idle - last_idle
                delta_total = curr_total - last_total
                if delta_total > 0:
                    cpu_percent = int(max(0, min(100, (1.0 - (delta_idle / delta_total)) * 100)))
                last_idle = curr_idle
                last_total = curr_total
                last_cpu_check = now
                print(json.dumps({"cpu": cpu_percent}))

            # 4. Heartbeat every 5 seconds
            if now - last_heartbeat >= 5.0:
                print(json.dumps({"heartbeat": True}))
                last_heartbeat = now

            time.sleep(0.08 if typed_now else 0.12)

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

