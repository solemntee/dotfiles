#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Please install it first: https://brew.sh/" >&2
  exit 1
fi

brew bundle --file="$ROOT/install/Brewfile"

if command -v pipx >/dev/null 2>&1; then
  pipx ensurepath >/dev/null 2>&1 || true
fi

echo "macOS base packages installed."
echo "Next steps:"
echo "  1. Install fonts: Sarasa Mono SC, Noto Color Emoji"
echo "  2. Run: $ROOT/install/link.sh"
echo "  3. Install im-select if you want Neovim input source auto switching"
echo "  4. Install Karabiner-Elements if you want global keyboard remaps"
echo "  5. Manually install apps you don't want in Brewfile, such as Clash and CCSwitch"
