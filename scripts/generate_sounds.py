#!/usr/bin/env python3
"""
Sound effects synthesizer for Omarchy Bar Pet (bol.bar-pet).
Generates gentle, pleasant sound effects in WAV format using Python standard library.
"""

import math
import os
import struct
import wave

def generate_wav(filepath, duration_sec, sample_rate, sample_func):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    num_samples = int(duration_sec * sample_rate)
    with wave.open(filepath, "w") as wav_file:
        wav_file.setnchannels(1) # mono
        wav_file.setsampwidth(2) # 16-bit
        wav_file.setframerate(sample_rate)
        
        frames = bytearray()
        for i in range(num_samples):
            t = i / sample_rate
            val = sample_func(t, duration_sec)
            val = max(-1.0, min(1.0, val))
            sample_16 = int(val * 32767.0)
            frames.extend(struct.pack("<h", sample_16))
        wav_file.writeframes(frames)

def make_purr(t, dur):
    # Modulated low warm purr (around 32Hz amplitude modulated at 16Hz)
    env = math.sin(math.pi * t / dur)
    rumble = math.sin(2 * math.pi * 35 * t) * (0.5 + 0.5 * math.sin(2 * math.pi * 18 * t))
    soft_harm = 0.25 * math.sin(2 * math.pi * 70 * t)
    return (rumble + soft_harm) * env * 0.45

def make_snack(t, dur):
    # Two quick cute chomp/pop bubbles
    val = 0.0
    # Chomp 1 (0 to 0.12s)
    if t < 0.12:
        t1 = t / 0.12
        env1 = math.exp(-12 * t1)
        freq1 = 550 - 200 * t1
        val += math.sin(2 * math.pi * freq1 * t) * env1 * 0.4
    # Chomp 2 (0.10 to 0.25s)
    if t >= 0.08:
        t2 = (t - 0.08) / 0.17
        env2 = math.exp(-10 * t2)
        freq2 = 700 - 250 * t2
        val += math.sin(2 * math.pi * freq2 * (t - 0.08)) * env2 * 0.45
    return val

def make_click(t, dur):
    # Crisp gentle UI blip (high soft ping with fast decay)
    env = math.exp(-35 * (t / dur))
    return math.sin(2 * math.pi * 1200 * t) * env * 0.25

def main():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "sounds"))
    generate_wav(os.path.join(base_dir, "purr.wav"), 0.5, 44100, make_purr)
    generate_wav(os.path.join(base_dir, "snack.wav"), 0.25, 44100, make_snack)
    generate_wav(os.path.join(base_dir, "click.wav"), 0.06, 44100, make_click)
    print(f"Generated sound effects in {base_dir}")

if __name__ == "__main__":
    main()
