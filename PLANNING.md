# Architectural Plan & Specification: Omarchy Bar Pet (`bol.bar-pet`)

A charming, reactive, and animated desktop pet for the **Omarchy Quattro** status bar (`omarchy-shell`), combining the iconic **Bongo Cat** typing & music mechanics with a **crisp Retro Pixel Art** aesthetic.

---

## 1. Why "Pixel Bongo Cat" is the Best Fit

Between Classic Vector Bongo and Retro Pixel Art, **Pixel Bongo Cat** is the winning recommendation for Omarchy:
1. **Aesthetic Harmony:** Omarchy pairs Hyprland with *JetBrains Mono Nerd Font*, CLI tools (CLIAMP, Alacritty, Neovim), and minimal borders. Pixel art matches this retro-modern monospace hacker aesthetic perfectly.
2. **Sharp at Small Scale:** Status bars are typically 28px - 36px in height. Vector blobs can lose distinct features when scaled down, whereas handcrafted pixel art (24x24 or 32x32) remains razor-sharp with crisp integer scaling.
3. **The Best of Both Worlds:** We take the legendary mechanics of Bongo Cat (paws tapping the desk as you type, bongo drums popping out when music plays) and render it in a gorgeous 16-bit pixel art style.

---

## 2. Directory & File Structure

```
~/Projects/omarchy-pet-widget/
├── manifest.json            # Plugin manifest (id: bol.bar-pet, kinds: ["bar-widget"])
├── BarWidget.qml            # Bar item with animated sprite rendering & click interaction
├── Panel.qml                # Popover drawer (status, feeding snacks, wardrobe/skins)
├── PetService.qml           # Reactive engine (keyboard activity, MPRIS audio, CPU, idle)
├── assets/
│   ├── sprites/
│   │   ├── idle.png         # Blinking, ear twitch, tail wag
│   │   ├── typing_l.png     # Left paw tap on desk
│   │   ├── typing_r.png     # Right paw tap on desk
│   │   ├── bongo_music.png  # Jamming / headbang with mini bongos
│   │   ├── sleep.png        # Curled up with floating 'Z' particles
│   │   ├── sweat.png        # High CPU stress animation
│   │   └── happy.png        # Heart emote / purring when petted
│   └── sounds/              # Optional subtle click / purr effects
├── install.sh               # Validation, file sync to ~/.config/omarchy/plugins, shell reload
├── uninstall.sh             # Clean uninstallation
├── README.md                # Documentation & configuration guide
└── PLANNING.md              # This specification document
```

---

## 3. Reactive State Engine (`PetService.qml`)

The pet responds dynamically to 5 real-time system signals without draining CPU or battery:

| State | Visual Behavior | Trigger & Detection Method |
|---|---|---|
| **Typing** | Alternating paws rapidly tapping desk/keyboard | Keystroke rate detection via evdev or window activity |
| **Jamming / Bongo** | Head-bobbing & drumming on mini bongos | Audio playing in CLIAMP or MPRIS (`playerctl status`) |
| **Heavy Load** | Sweating / smoke animation above head | System CPU usage > 75% (via `/proc/stat` or `omarchy-system-stats`) |
| **Sleeping** | Curled asleep with floating `Z z z` | Inactive for > 2 minutes (derived from Hyprland idle) |
| **Happy / Petted** | Closed-eye smile, hearts floating, purr | User mouse clicks on the bar widget |
| **Neutral Idle** | Breathing, periodic blink, tail wag | Default baseline state |

---

## 4. Bar Component (`BarWidget.qml`)

* **Rendering Engine:**
  - Uses QML `Image` with animated frames or a lightweight QML `Canvas` for zero-overhead pixel rendering.
  - Dynamic FPS throttling:
    - 15-20 FPS during active typing / jamming.
    - 2-4 FPS during idle breathing.
    - 1 FPS during sleep.
* **Interactivity:**
  - **Left-Click:** Pet the cat! (Instantly switches to `happy` state, emits floating heart particle, plays subtle purr sound).
  - **Right-Click / Middle-Click:** Opens the **Pet Care & Wardrobe Popover** (`Panel.qml`).
  - **Hover Tooltip:** Shows Pet Name, Mood status (e.g. *"Jamming to Spotify"*, *"Coding frenzy"*, *"Napping"*), and Energy level.

---

## 5. Care & Wardrobe Popover (`Panel.qml`)

Follows standard `qs.Ui.Panel` styling to seamlessly match Omarchy themes:

1. **Header & Pet Profile:**
   - Pixel avatar preview.
   - Pet Name (customizable, e.g., *"Archie"*, *"Luna"*, *"Mochi"*).
   - Mood tag: `Vibing` / `Focus Mode` / `Sleepy`.
2. **Energy & Snack Bar:**
   - Energy bar tied to laptop battery percentage (e.g., 85% battery = 85% energy).
   - Interactive snack buttons:
     - 🐟 **Fish:** Restores full happiness immediately.
     - ☕ **Coffee:** Triggers high-speed typing animation and hyper eyes for 10 seconds.
     - 🥛 **Milk:** Sends pet to sleep peacefully.
3. **Wardrobe / Skin Switcher:**
   - 🐱 **Pixel Tuxedo / Calico Cat** (Default)
   - 🥁 **Classic Bongo Cat** (Clean white vector style)
   - 🐶 **Retro Pixel Shiba Inu**
   - 🕶️ **Cyberpunk Cat** (Neon sunglasses & cyber collar)
4. **Settings Toggles:**
   - Toggle audio reactivity (on/off).
   - Toggle typing reactivity (on/off).
   - Sound effects mute switch.

---

## 6. Implementation Steps Checklist

- [x] **Step 1: Manifest Definition** - Create `manifest.json` with plugin metadata and setting defaults.
- [x] **Step 2: Pixel Asset Creation** - Prepare crisp 24x24 / 32x32 pixel sprites for all animation states.
- [x] **Step 3: State Service Engine** - Implement `PetService.qml` with unprivileged MPRIS, CPU, and idle watchers.
- [x] **Step 4: Bar Widget Renderer** - Implement `BarWidget.qml` with dynamic frame animation and click reactions.
- [x] **Step 5: Interactive Popover** - Implement `Panel.qml` with snack bar, mood meters, and skin changer.
- [x] **Step 6: Lifecycle Scripts** - Create `install.sh` and `uninstall.sh`.
- [x] **Step 7: Testing & Verification** - Validate with `omarchy plugin validate`, install to Omarchy shell, and verify typing/music reactions.

