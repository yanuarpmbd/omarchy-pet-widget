# Omarchy Bar Pet (`bol.bar-pet`) 🐾

A charming, reactive, and animated desktop pet for the **Omarchy Quattro** status bar (`omarchy-shell`). Inspired by the iconic **Bongo Cat** typing & drumming mechanics, rendered in a crisp retro 16-bit pixel art aesthetic.

---

## ✨ Features

- 🎹 **Typing Reactivity:** Alternating paws rapidly tap the desk/keyboard as you type in any application.
- 🥁 **Bongo Jamming:** Whips out mini bongos and drums along when music or video audio is playing (MPRIS & Pipewire streams).
- 💤 **Idle Napping:** Automatically curls up and falls asleep with floating `Z z z` particles after a configurable period of inactivity.
- 💨 **CPU Stress:** Sweats and puffs when system CPU utilization exceeds the stress threshold (>75%).
- 💖 **Interactive Petting:** Left-click on the pet on the status bar to pet it, triggering closed-eye smiles, floating hearts, and subtle purring!
- 🍱 **Care & Snack Bar:**
  - 🐟 **Fish:** Restores happiness and boosts energy.
  - ☕ **Coffee:** Triggers 10 seconds of blazing fast typing zoomies.
  - 🥛 **Milk:** Puts pet into a peaceful power nap.
- 🎭 **Wardrobe & Skin Switcher:**
  - 🐱 **Pixel Cat (Tuxedo)** - Classic black & white cat with pink paw pads.
  - 🥁 **Classic Bongo Cat** - Clean white vector/pixel Bongo Cat.
  - 🐶 **Shiba Inu** - Golden tan pixel Shiba with curled tail.
  - 🕶️ **Cyberpunk Cat** - Slate cyber feline with glowing neon cyan visor.

---

## 🚀 Installation

From the project repository:

```bash
./install.sh
```

This will:
1. Validate the plugin with `omarchy plugin validate`.
2. Generate all 32x32 pixel sprites and sound effects.
3. Sync files to `~/.config/omarchy/plugins/bol.bar-pet/`.
4. Enable the plugin on the right section of the status bar.
5. Restart the Omarchy shell to load the widget.

### Uninstallation

```bash
./uninstall.sh
```

---

## 🎮 Controls & Shortcuts

| Action | Control | Description |
|---|---|---|
| **Care & Wardrobe Popover** | `Left-Click` or `Right-Click` on bar | Opens the Care & Wardrobe Popover drawer |
| **Quick Pet** | `Middle-Click` on bar or `P` in popover | Triggers purr, happy face, and floating hearts |
| **Feed Fish** | `F` in popover | Gives fish, boosts happiness and energy |
| **Give Coffee** | `C` in popover | Triggers 10s of hyper bongo zoomies |
| **Give Milk** | `M` in popover | Sends pet for a relaxing power nap |
| **Switch Skin** | `1` - `4` in popover | 1: Tuxedo Cat, 2: Bongo, 3: Shiba, 4: Cyberpunk |
| **Close Popover** | `Esc` | Closes the popover drawer |


---

## ⚙️ Configuration

You can configure options in `~/.config/omarchy/shell.json` under the widget entry:

```json
{
  "id": "bol.bar-pet",
  "petName": "Archie",
  "skin": "pixel_cat",
  "typingReactive": true,
  "audioReactive": true,
  "soundEffects": true,
  "idleSleepTimeout": 120,
  "cpuHighThreshold": 75
}
```

Or configure dynamically via Omarchy CLI:

```bash
omarchy bar set bol.bar-pet petName "Luna"
omarchy bar set bol.bar-pet skin "classic_bongo"
omarchy bar set bol.bar-pet audioReactive true
```

---

## 📡 IPC Interface

Communicate with the pet directly from the terminal or keybindings using Omarchy IPC:

```bash
# Pet the cat
omarchy shell bol.bar-pet pet

# Feed snacks
omarchy shell bol.bar-pet feed "fish"
omarchy shell bol.bar-pet feed "coffee"
omarchy shell bol.bar-pet feed "milk"

# Switch wardrobe skins
omarchy shell bol.bar-pet setSkin "cyberpunk"
omarchy shell bol.bar-pet setSkin "classic_bongo"
omarchy shell bol.bar-pet setSkin "shiba"
omarchy shell bol.bar-pet setSkin "pixel_cat"

# Toggle popover panel
omarchy shell bol.bar-pet toggle

# Get pet status JSON
omarchy shell bol.bar-pet status
```


---

## 📂 Project Structure

```
~/Projects/omarchy-pet-widget/
├── manifest.json            # Plugin manifest (bol.bar-pet)
├── BarWidget.qml            # Bar item with pixel art rendering & click triggers
├── Panel.qml                # Care & Wardrobe popover drawer
├── PetService.qml           # Reactive engine (keyboard, MPRIS, CPU, idle, UPower)
├── pet_watcher.py           # Zero-overhead unprivileged typing & CPU watcher
├── scripts/
│   ├── generate_sprites.py  # Standalone 32x32 pixel art PNG generator
│   └── generate_sounds.py   # PCM wave sound synthesizer
├── assets/
│   ├── sprites/             # 28 handcrafted 32x32 retro pixel art sprites
│   └── sounds/              # Audio effects (purr, snack, click)
├── install.sh               # Validation, sync, enable, and shell reload
├── uninstall.sh             # Removal script
├── README.md                # Documentation
└── PLANNING.md              # Architectural specification
```

---

## 📄 License

MIT © [bol](https://github.com/bol)
