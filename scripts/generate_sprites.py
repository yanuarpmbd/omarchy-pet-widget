#!/usr/bin/env python3
"""
Pixel sprite generator for Omarchy Bar Pet (bol.bar-pet).
Generates crisp 32x32 retro pixel art PNGs without third-party dependencies.
"""

import os
import struct
import zlib

def make_png(width, height, rgba_pixels):
    """Write an RGBA image array to PNG byte string."""
    def chunk(tag, data):
        return struct.pack("!I", len(data)) + tag + data + struct.pack("!I", zlib.crc32(tag + data) & 0xffffffff)
    raw = bytearray()
    for y in range(height):
        raw.append(0) # filter type 0: None
        for x in range(width):
            raw.extend(rgba_pixels[y][x])
    ihdr = struct.pack("!IIBBBBB", width, height, 8, 6, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")

class PixelCanvas:
    def __init__(self, width=32, height=32):
        self.w = width
        self.h = height
        self.clear()

    def clear(self):
        self.pixels = [[(0, 0, 0, 0) for _ in range(self.w)] for _ in range(self.h)]

    def set(self, x, y, color):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.pixels[y][x] = color

    def rect(self, x, y, w, h, color):
        for cy in range(y, y + h):
            for cx in range(x, x + w):
                self.set(cx, cy, color)

    def outline_rect(self, x, y, w, h, fill_color, border_color):
        self.rect(x, y, w, h, fill_color)
        for cx in range(x, x + w):
            self.set(cx, y, border_color)
            self.set(cx, y + h - 1, border_color)
        for cy in range(y, y + h):
            self.set(x, cy, border_color)
            self.set(x + w - 1, cy, border_color)

    def circle(self, cx, cy, r, color):
        for y in range(cy - r, cy + r + 1):
            for x in range(cx - r, cx + r + 1):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r ** 2:
                    self.set(x, y, color)

    def save(self, filepath):
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        data = make_png(self.w, self.h, self.pixels)
        with open(filepath, "wb") as f:
            f.write(data)

# Common palette
C_TRANS = (0, 0, 0, 0)
C_BLACK = (24, 24, 28, 255)
C_DARK_DESK = (60, 42, 33, 255)
C_DESK_TOP = (112, 75, 52, 255)
C_DESK_EDGE = (142, 98, 70, 255)
C_KEYBOARD = (38, 42, 50, 255)
C_KEY_ACCENT = (120, 180, 240, 255)
C_BONGO_WOOD = (168, 102, 50, 255)
C_BONGO_HEAD = (240, 226, 195, 255)
C_BONGO_RIM = (90, 52, 24, 255)
C_HEART = (245, 68, 114, 255)
C_SWEAT = (80, 190, 250, 255)
C_ZZZ = (140, 180, 255, 255)
C_BLUSH = (255, 140, 160, 255)

def draw_desk_and_keys(cv, has_bongo=False):
    # Desk baseline (bottom rows 25-31)
    cv.rect(0, 26, 32, 6, C_DESK_TOP)
    cv.rect(0, 25, 32, 1, C_DESK_EDGE)
    cv.rect(0, 30, 32, 2, C_DARK_DESK)

    if not has_bongo:
        # Mini keyboard on desk
        cv.rect(6, 26, 20, 4, C_KEYBOARD)
        for kx in range(8, 24, 3):
            cv.set(kx, 27, (180, 190, 205, 255))
            cv.set(kx, 28, (140, 150, 165, 255))
    else:
        # Mini twin bongos
        # Left bongo
        cv.rect(7, 24, 8, 2, C_BONGO_RIM)
        cv.rect(8, 23, 6, 2, C_BONGO_HEAD)
        cv.rect(8, 26, 6, 4, C_BONGO_WOOD)
        # Right bongo
        cv.rect(17, 24, 8, 2, C_BONGO_RIM)
        cv.rect(18, 23, 6, 2, C_BONGO_HEAD)
        cv.rect(18, 26, 6, 4, C_BONGO_WOOD)

def render_skin_state(skin, state, out_path):
    cv = PixelCanvas(32, 32)
    has_bongo = (state == "bongo")
    draw_desk_and_keys(cv, has_bongo)

    # Theme colors
    if skin == "pixel_cat":
        c_body = (38, 38, 44, 255)       # Tuxedo dark charcoal
        c_belly = (245, 245, 250, 255)    # White patch
        c_outline = (16, 16, 20, 255)
        c_paws = (250, 250, 255, 255)
        c_ear_in = (245, 160, 175, 255)
        c_eyes = (255, 210, 60, 255)      # Amber/Gold eyes
        c_pupil = (20, 20, 24, 255)
        c_nose = (245, 140, 160, 255)
    elif skin == "classic_bongo":
        c_body = (250, 250, 252, 255)    # Pure bongo cat white
        c_belly = (255, 255, 255, 255)
        c_outline = (25, 25, 30, 255)
        c_paws = (250, 250, 252, 255)
        c_ear_in = (245, 175, 190, 255)
        c_eyes = (30, 30, 35, 255)       # Black dot eyes
        c_pupil = (240, 240, 245, 255)
        c_nose = (230, 130, 150, 255)
    elif skin == "shiba":
        c_body = (222, 148, 70, 255)     # Golden shiba tan
        c_belly = (250, 242, 230, 255)   # Cream muzzle & chest
        c_outline = (85, 48, 20, 255)
        c_paws = (250, 245, 235, 255)
        c_ear_in = (210, 120, 110, 255)
        c_eyes = (32, 20, 14, 255)
        c_pupil = (255, 255, 255, 255)
        c_nose = (25, 18, 14, 255)
    elif skin == "cyberpunk":
        c_body = (40, 48, 62, 255)       # Cyber slate blue
        c_belly = (30, 36, 48, 255)
        c_outline = (15, 20, 30, 255)
        c_paws = (70, 85, 105, 255)
        c_ear_in = (0, 235, 215, 255)    # Glowing cyan ear tech
        c_eyes = (255, 40, 130, 255)     # Neon pink / visor
        c_pupil = (0, 255, 240, 255)
        c_nose = (0, 230, 215, 255)

    head_y = 10
    head_h = 12
    head_w = 16
    head_x = 8

    # Sleeping adjusts posture down
    if state == "sleep":
        head_y = 13

    # --- EARS ---
    if skin == "shiba":
        # Shiba triangular folded ears
        cv.rect(head_x + 1, head_y - 4, 4, 5, c_body)
        cv.rect(head_x + head_w - 5, head_y - 4, 4, 5, c_body)
        cv.rect(head_x + 2, head_y - 3, 2, 3, c_ear_in)
        cv.rect(head_x + head_w - 4, head_y - 3, 2, 3, c_ear_in)
    else:
        # Cat pointed ears
        # Left ear
        cv.set(head_x + 2, head_y - 5, c_outline)
        cv.rect(head_x + 1, head_y - 4, 3, 2, c_body)
        cv.rect(head_x + 1, head_y - 2, 4, 3, c_body)
        cv.rect(head_x + 2, head_y - 3, 2, 2, c_ear_in)
        # Right ear
        cv.set(head_x + head_w - 3, head_y - 5, c_outline)
        cv.rect(head_x + head_w - 4, head_y - 4, 3, 2, c_body)
        cv.rect(head_x + head_w - 5, head_y - 2, 4, 3, c_body)
        cv.rect(head_x + head_w - 4, head_y - 3, 2, 2, c_ear_in)

    # --- BODY & HEAD ---
    # Body base behind desk
    cv.rect(head_x - 1, head_y + 4, head_w + 2, 12, c_body)
    # Head block
    cv.rect(head_x, head_y, head_w, head_h, c_body)
    # Head outline accents
    cv.rect(head_x - 1, head_y + 1, 1, head_h - 2, c_outline)
    cv.rect(head_x + head_w, head_y + 1, 1, head_h - 2, c_outline)
    cv.rect(head_x + 2, head_y - 1, head_w - 4, 1, c_outline)

    # Belly / chest patch
    if skin == "pixel_cat":
        cv.rect(head_x + 5, head_y + 6, 6, 7, c_belly)
        cv.set(head_x + 6, head_y + 5, c_belly)
        cv.set(head_x + 9, head_y + 5, c_belly)
    elif skin == "shiba":
        # White cheeks / muzzle
        cv.rect(head_x + 2, head_y + 6, 12, 6, c_belly)
        # Eyebrow dots!
        cv.rect(head_x + 3, head_y + 1, 2, 2, c_belly)
        cv.rect(head_x + head_w - 5, head_y + 1, 2, 2, c_belly)
    elif skin == "classic_bongo":
        # Pure clean bongo aesthetic
        pass
    elif skin == "cyberpunk":
        # Cyber collar / line
        cv.rect(head_x + 2, head_y + head_h - 2, head_w - 4, 1, (0, 240, 255, 255))
        cv.set(head_x + 7, head_y + head_h - 1, (255, 30, 120, 255))
        cv.set(head_x + 8, head_y + head_h - 1, (255, 30, 120, 255))

    # --- FACIAL EXPRESSIONS ---
    if state in ("idle", "typing_l", "typing_r", "bongo"):
        if skin == "cyberpunk":
            # Cyber visor across eyes
            cv.rect(head_x + 2, head_y + 3, 12, 4, (18, 24, 38, 255))
            cv.rect(head_x + 3, head_y + 4, 10, 2, (0, 255, 240, 255))
            cv.set(head_x + 5, head_y + 4, (255, 40, 140, 255))
            cv.set(head_x + 9, head_y + 4, (255, 40, 140, 255))
        elif skin == "classic_bongo":
            # Bongo cat black dot eyes
            cv.rect(head_x + 4, head_y + 4, 2, 2, c_eyes)
            cv.rect(head_x + head_w - 6, head_y + 4, 2, 2, c_eyes)
            # Subtle mouth curve
            cv.set(head_x + 7, head_y + 7, c_outline)
            cv.set(head_x + 8, head_y + 7, c_outline)
        else:
            # Cute big pixel eyes
            cv.rect(head_x + 3, head_y + 3, 3, 3, c_eyes)
            cv.rect(head_x + head_w - 6, head_y + 3, 3, 3, c_eyes)
            cv.set(head_x + 4, head_y + 4, c_pupil)
            cv.set(head_x + head_w - 5, head_y + 4, c_pupil)
            # Nose and mouth
            cv.set(head_x + 7, head_y + 6, c_nose)
            cv.set(head_x + 8, head_y + 6, c_nose)
            cv.set(head_x + 6, head_y + 7, c_outline)
            cv.set(head_x + 9, head_y + 7, c_outline)

    elif state == "happy":
        # Closed joyful happy curved eyes (^ ^)
        cv.set(head_x + 3, head_y + 4, c_outline)
        cv.set(head_x + 4, head_y + 3, c_outline)
        cv.set(head_x + 5, head_y + 4, c_outline)
        cv.set(head_x + head_w - 6, head_y + 4, c_outline)
        cv.set(head_x + head_w - 5, head_y + 3, c_outline)
        cv.set(head_x + head_w - 4, head_y + 4, c_outline)
        # Blush cheeks!
        cv.rect(head_x + 2, head_y + 6, 2, 1, C_BLUSH)
        cv.rect(head_x + head_w - 4, head_y + 6, 2, 1, C_BLUSH)
        # Big smile :3
        cv.set(head_x + 7, head_y + 6, c_nose)
        cv.set(head_x + 8, head_y + 6, c_nose)
        cv.set(head_x + 6, head_y + 7, c_outline)
        cv.set(head_x + 7, head_y + 8, c_outline)
        cv.set(head_x + 8, head_y + 8, c_outline)
        cv.set(head_x + 9, head_y + 7, c_outline)
        # Little floating heart above right ear
        cv.set(25, 4, C_HEART)
        cv.set(27, 4, C_HEART)
        cv.rect(24, 5, 5, 1, C_HEART)
        cv.rect(25, 6, 3, 1, C_HEART)
        cv.set(26, 7, C_HEART)

    elif state == "sleep":
        # Sleeping horizontal slit eyes (- -)
        cv.rect(head_x + 3, head_y + 4, 3, 1, c_outline)
        cv.rect(head_x + head_w - 6, head_y + 4, 3, 1, c_outline)
        # Nose
        cv.set(head_x + 7, head_y + 6, c_nose)
        cv.set(head_x + 8, head_y + 6, c_nose)
        # Floating Z z z particles
        # Big Z
        cv.rect(24, 3, 4, 1, C_ZZZ)
        cv.set(26, 4, C_ZZZ)
        cv.set(25, 5, C_ZZZ)
        cv.rect(24, 6, 4, 1, C_ZZZ)
        # Small z
        cv.rect(21, 8, 3, 1, C_ZZZ)
        cv.set(22, 9, C_ZZZ)
        cv.rect(21, 10, 3, 1, C_ZZZ)

    elif state == "sweat":
        # High CPU stress - wide panicked eyes
        cv.rect(head_x + 3, head_y + 3, 3, 3, (255, 255, 255, 255))
        cv.rect(head_x + head_w - 6, head_y + 3, 3, 3, (255, 255, 255, 255))
        cv.set(head_x + 4, head_y + 4, c_outline)
        cv.set(head_x + head_w - 5, head_y + 4, c_outline)
        # Open wavy mouth
        cv.rect(head_x + 6, head_y + 7, 4, 2, c_outline)
        cv.set(head_x + 7, head_y + 7, (240, 100, 110, 255))
        cv.set(head_x + 8, head_y + 7, (240, 100, 110, 255))
        # Sweat droplet on head
        cv.set(5, 5, C_SWEAT)
        cv.rect(4, 6, 3, 2, C_SWEAT)
        cv.rect(5, 8, 2, 1, C_SWEAT)

    # --- PAWS & DESK INTERACTION ---
    paw_y = 23

    if state in ("idle", "sleep"):
        # Both paws resting peacefully on desk
        cv.rect(head_x + 1, paw_y, 4, 3, c_paws)
        cv.rect(head_x + head_w - 5, paw_y, 4, 3, c_paws)
        cv.rect(head_x + 1, paw_y + 2, 4, 1, c_outline)
        cv.rect(head_x + head_w - 5, paw_y + 2, 4, 1, c_outline)

    elif state == "typing_l":
        # Left paw slammed down onto keys
        cv.rect(head_x, paw_y + 2, 5, 3, c_paws)
        cv.rect(head_x, paw_y + 4, 5, 1, c_outline)
        # Right paw raised up in the air!
        cv.rect(head_x + head_w - 4, paw_y - 4, 4, 4, c_paws)
        cv.rect(head_x + head_w - 4, paw_y - 1, 4, 1, c_outline)

    elif state == "typing_r":
        # Left paw raised in the air!
        cv.rect(head_x, paw_y - 4, 4, 4, c_paws)
        cv.rect(head_x, paw_y - 1, 4, 1, c_outline)
        # Right paw slammed down onto keys
        cv.rect(head_x + head_w - 5, paw_y + 2, 5, 3, c_paws)
        cv.rect(head_x + head_w - 5, paw_y + 4, 5, 1, c_outline)

    elif state == "bongo":
        # Both paws slamming the bongo drums
        cv.rect(9, 21, 4, 3, c_paws)
        cv.rect(19, 21, 4, 3, c_paws)
        cv.rect(9, 23, 4, 1, c_outline)
        cv.rect(19, 23, 4, 1, c_outline)
        # Musical note floating above head
        cv.set(4, 5, (255, 200, 50, 255))
        cv.set(5, 5, (255, 200, 50, 255))
        cv.set(5, 6, (255, 200, 50, 255))
        cv.set(5, 7, (255, 200, 50, 255))
        cv.rect(3, 8, 3, 2, (255, 200, 50, 255))

    elif state == "happy":
        # Paws resting excitedly on desk edge with pink pads showing
        cv.rect(head_x + 1, paw_y - 1, 4, 3, c_paws)
        cv.rect(head_x + head_w - 5, paw_y - 1, 4, 3, c_paws)
        cv.set(head_x + 2, paw_y, C_BLUSH)
        cv.set(head_x + head_w - 4, paw_y, C_BLUSH)

    elif state == "sweat":
        # Nervous paws trembling on desk
        cv.rect(head_x + 2, paw_y + 1, 4, 3, c_paws)
        cv.rect(head_x + head_w - 6, paw_y + 1, 4, 3, c_paws)

    cv.save(out_path)

def generate_all_sprites():
    skins = ["pixel_cat", "classic_bongo", "shiba", "cyberpunk"]
    states = ["idle", "typing_l", "typing_r", "bongo", "sleep", "sweat", "happy"]
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "sprites"))

    total = 0
    for skin in skins:
        for state in states:
            path = os.path.join(base_dir, skin, f"{state}.png")
            render_skin_state(skin, state, path)
            total += 1
    print(f"Successfully generated {total} pixel sprites across {len(skins)} skins in {base_dir}")

if __name__ == "__main__":
    generate_all_sprites()
