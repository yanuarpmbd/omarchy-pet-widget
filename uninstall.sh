#!/usr/bin/env bash
# ==============================================================================
# Uninstaller for Omarchy Bar Pet (bol.bar-pet)
# Disables plugin, removes plugin directory, and reloads the shell.
# ==============================================================================

set -euo pipefail

PLUGIN_ID="bol.bar-pet"
TARGET_DIR="${HOME}/.config/omarchy/plugins/${PLUGIN_ID}"

echo "🐾 [1/3] Disabling ${PLUGIN_ID} in Omarchy shell..."
omarchy plugin disable "$PLUGIN_ID" || true

echo "🐾 [2/3] Removing plugin directory from ${TARGET_DIR}..."
if [[ -d "$TARGET_DIR" ]]; then
  rm -rf "$TARGET_DIR"
  echo "  ✓ Removed ${TARGET_DIR}"
fi

echo "🐾 [3/3] Reloading Omarchy shell..."
if command -v omarchy >/dev/null 2>&1; then
  omarchy restart shell || true
fi

echo "✨ Successfully uninstalled ${PLUGIN_ID}."
