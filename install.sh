#!/usr/bin/env bash
# ==============================================================================
# Installer for Omarchy Bar Pet (bol.bar-pet)
# Validates plugin, syncs to ~/.config/omarchy/plugins, enables, and reloads.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="bol.bar-pet"
TARGET_DIR="${HOME}/.config/omarchy/plugins/${PLUGIN_ID}"

echo "🐾 [1/5] Validating plugin against Omarchy manifest schema..."
omarchy plugin validate "$SCRIPT_DIR"
echo "  ✓ Manifest and entrypoints are valid."

echo "🐾 [2/5] Ensuring assets are freshly generated..."
python3 "$SCRIPT_DIR/scripts/generate_sprites.py"
python3 "$SCRIPT_DIR/scripts/generate_sounds.py"
chmod +x "$SCRIPT_DIR/pet_watcher.py"

echo "🐾 [3/5] Syncing plugin files to ${TARGET_DIR}..."
mkdir -p "$TARGET_DIR"
rsync -av --delete \
  --exclude ".git" \
  --exclude "__pycache__" \
  --exclude "*.swp" \
  "$SCRIPT_DIR/" "$TARGET_DIR/"
chmod +x "$TARGET_DIR/pet_watcher.py"

echo "🐾 [4/5] Enabling plugin on the status bar (between weather and tray)..."
if omarchy plugin list | grep -q "$PLUGIN_ID"; then
  omarchy plugin enable "$PLUGIN_ID" --section center --after omarchy.weather || true
fi

echo "🐾 [5/5] Reloading Omarchy shell..."
if command -v omarchy >/dev/null 2>&1; then
  omarchy restart shell || true
fi

echo "✨ Successfully installed ${PLUGIN_ID}!"
echo "   - Left-click pet on the bar: Care Drawer"
echo "   - Middle-click pet on the bar: Pet & Purr"
echo "   - Keyboard shortcuts in drawer: [P] Pet, [F] Snack, [C] Coffee, [M] Milk, [1-4] Pets"
