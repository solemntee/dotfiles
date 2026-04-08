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
echo "  1. Run: $ROOT/install/setup-user-binaries.sh"
echo "  2. Run: $ROOT/install/link.sh"
echo "  3. On Ubuntu GNOME, keep only US in desktop input sources:"
echo "     gsettings set org.gnome.desktop.input-sources sources \"[('xkb', 'us')]\""
echo "     gsettings set org.gnome.desktop.input-sources mru-sources \"[('xkb', 'us')]\""
echo "  4. On Ubuntu GNOME, mask the built-in ibus user service:"
echo "     systemctl --user mask --now org.freedesktop.IBus.session.GNOME.service"
echo "  5. If needed, copy $ROOT/linux/keyd/default.conf to /etc/keyd/default.conf"
