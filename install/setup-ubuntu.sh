#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This script is intended for Ubuntu or Debian-based systems." >&2
  exit 1
fi

mapfile -t packages < <(grep -vE '^\s*(#|$)' "$ROOT/install/apt-packages.txt")

sudo apt-get update
sudo apt-get install -y "${packages[@]}"

if command -v pipx >/dev/null 2>&1; then
  pipx ensurepath >/dev/null 2>&1 || true
fi

echo "Ubuntu base packages installed."
echo "Next steps:"
echo "  1. Install fonts: Sarasa Mono SC, Noto Color Emoji"
echo "  2. Run: $ROOT/install/link.sh"
echo "  3. If needed, copy $ROOT/linux/keyd/default.conf to /etc/keyd/default.conf"
