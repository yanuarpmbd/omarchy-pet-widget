# Omarchy Bar Pet (`bol.bar-pet`) 🐾

A delightful, reactive, and animated desktop pet widget designed specifically for the **Omarchy Quattro** status bar (`omarchy-shell` / Quickshell). Rendered in a clean, minimalist continuous vector line art aesthetic that dynamically inherits your Omarchy theme foreground colors.

---

## ✨ Features

- 🐇 **4 Handcrafted Vector Animals:**
  - 🐱 **Cat (`cat`)** - Minimalist feline with expressive tail wag, paw strides, and purr smiles.
  - 🍊 **Capybara (`capy`)** - Calm, zen capybara carrying a bouncing yuzu fruit on its head.
  - 🐕 **Shiba Inu (`dog`)** - Cheerful Shiba with alert triangle ears and curled tail.
  - 🐇 **Bunny (`bunny`)** - Authentic hopping kinematics with parabolic vertical leap arc, synchronized hind-leg kicks, and ear momentum physics.
- 🛣️ **Dynamic Adaptive Runway:**
  - Intelligently expands to fill the available status bar gap between the center weather widget and the right modules (tray, network, audio).
  - Supports 3 runway modes: `auto` (adaptive fill), `fixed` (custom width), and `compact` (single icon slot).
- ⚡ **4-Tier Energy & Sloth System (Battery + Snack Bonuses):**
  - Tied to your laptop battery (`UPower`) plus snack energy boosts (up to +80% bonus).
  - **Exhausted / Critical (10% – 25%):** Pet never walks or roams along the bar (`0 px/s`). Alternates between sitting quietly and deep exhausted napping. Even if music plays, it stays resting. **Laptop typing reactivity still works!**
  - **Low Energy (25% – 50%):** Sluggish movement (0.50–0.65x speed), short walks (3.5–7s), long sits (12–18s), and a 35% chance of spontaneous catnaps while sitting.
  - **Medium Energy (50% – 75%):** Balanced roaming and resting with steady movement speed.
  - **High Energy (75% – 100%):** Energetic, brisk movement (0.95–1.12x speed) with long strolls and short breathers.
- 🎧 **Audio & Music Reactivity:**
  - Wears mini glowing headphones and floats musical notes (`♪`, `♫`) when listening to music or video streams (via MPRIS & Pipewire).
- 💻 **Typing Reactivity:**
  - Pops open a mini laptop with a glowing Omarchy logo and taps alternating paws on the keyboard in real-time as you type in any application.
- 💤 **Idle Sleep & 💨 CPU Stress Reactivity:**
  - Automatically curls up and falls asleep with floating `z Z z` particles after a period of inactivity.
  - Sweats and puffs when system CPU load exceeds the stress threshold (>75%).
- 🏷️ **Custom Pet Naming:**
  - Rename your pet anytime right from the Care Drawer header or via the CLI!
- 🍱 **Care & Snacks Drawer:**
  - 💖 **Petting:** Restores happiness, triggers floating hearts `♥`, and plays gentle purr audio (+4% energy).
  - 🥕/🐟/🍊/🦴 **Favorite Snack:** Adaptive to current animal (Fish for cat, Yuzu for capy, Bone for dog, Carrot for bunny) (+15% energy).
  - ☕ **Coffee:** Triggers 10 seconds of fast typing zoomies (+8% energy).
  - 🥛 **Milk:** Sends the pet into a peaceful power nap (+8% energy).
- 🔒 **Privacy-First & Secure:**
  - Keystroke activity is counted in unprivileged read-only mode via `/proc/interrupts` or `/dev/input/`.
  - **Zero keystroke logging**: No keycodes, characters, or text are ever read, recorded, or transmitted.

---

## 🚀 Installation & Setup

From the repository root:

```bash
./install.sh
```

The script will:
1. Validate the plugin with `omarchy plugin validate`.
2. Generate synthesizer sound effects (`click.wav`, `purr.wav`, `snack.wav`).
3. Sync files to `~/.config/omarchy/plugins/bol.bar-pet/`.
4. Enable and position the widget on the Omarchy status bar.
5. Reload the Omarchy shell.

### Uninstallation

```bash
./uninstall.sh
```

---

## 🎮 Controls & Shortcuts

| Action | Control | Description |
|---|---|---|
| **Toggle Care Drawer** | `Left-Click` on pet | Opens/closes the Care Drawer popover |
| **Quick Pet** | `Middle-Click` on pet or `P` in drawer | Pets pet, purrs, emits hearts (+4% energy) |
| **Favorite Snack** | `F` in drawer | Feeds animal's favorite treat (+15% energy) |
| **Give Coffee** | `C` in drawer | Triggers typing zoomies (+8% energy) |
| **Give Milk** | `M` in drawer | Puts pet to sleep (+8% energy) |
| **Rename Pet** | `N` in drawer (or edit icon) | Edit pet name inline with Enter / Esc |
| **Select Animal** | `1` – `4` in drawer | 1: Cat, 2: Capybara, 3: Shiba Inu, 4: Bunny |
| **Close Drawer** | `Esc` | Closes the drawer popover |

---

## ⚙️ Configuration

Settings are stored in `~/.config/omarchy/shell.json` under the widget entry:

```json
{
  "id": "bol.bar-pet",
  "petName": "Turtle",
  "animal": "cat",
  "runwayMode": "auto",
  "runwayWidth": 160,
  "maxRunwayWidth": 0,
  "typingReactive": true,
  "audioReactive": true,
  "soundEffects": true,
  "idleSleepTimeout": 120,
  "cpuHighThreshold": 75
}
```

---

## 📡 IPC Interface (CLI / Scripting)

Communicate with the pet directly from scripts, keybindings, or your terminal:

```bash
# Get pet status as JSON
omarchy shell bol.bar-pet status

# Open / Close / Toggle drawer
omarchy shell bol.bar-pet toggle
omarchy shell bol.bar-pet open
omarchy shell bol.bar-pet close

# Pet interaction
omarchy shell bol.bar-pet pet

# Feed snacks
omarchy shell bol.bar-pet feed "favorite"  # Adaptive favorite snack (+15%)
omarchy shell bol.bar-pet feed "coffee"    # Coffee (+8% & typing zoomies)
omarchy shell bol.bar-pet feed "milk"      # Milk (+8% & sleep)

# Rename pet
omarchy shell bol.bar-pet setName "Archie"

# Switch animal
omarchy shell bol.bar-pet setAnimal "bunny"   # "cat", "capy", "dog", "bunny"
```

---

## 📂 Project Structure

```
~/Projects/omarchy-pet-widget/
├── manifest.json            # Plugin manifest and schema (bol.bar-pet)
├── BarWidget.qml            # Bar item with dynamic adaptive runway & movement physics
├── Panel.qml                # Care Drawer (naming, snacks, animal cards, reactivity toggles)
├── PetRenderer.qml          # Pure vector line art canvas & state animation engine
├── PetService.qml           # Reactive engine (4 energy tiers, keyboard, MPRIS, UPower, idle)
├── pet_watcher.py           # Zero-overhead privacy-respecting keyboard & CPU monitor
├── scripts/
│   └── generate_sounds.py   # PCM sound synthesizer (purr, snack, click)
├── assets/
│   └── sounds/              # Generated audio effects (.wav)
├── install.sh               # Validation, file sync, auto-enable, and shell reload
├── uninstall.sh             # Clean uninstallation script
└── README.md                # Documentation
```

---

## 🛡️ Security & Performance Audit

- **Zero Elevated Privileges:** Operates completely within standard user permissions.
- **Privacy Guaranteed:** The typing watcher strictly detects keypress presence (to alternate paws); it **never reads, inspects, or logs keystroke values or text**.
- **Vector Rendering:** Eliminates bulky bitmap assets and scales cleanly on any HiDPI display without rasterization artifacts.
- **Resource Footprint:** Background CPU usage is negligible (<0.02%), with automatic FPS throttling when the pet is resting or sleeping.

---

## 📄 License

MIT © [bol](https://github.com/bol)
