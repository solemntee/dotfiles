#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This script is intended for Ubuntu or Debian-based systems." >&2
  exit 1
fi

install_keyd() {
  if apt-cache show keyd >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v add-apt-repository >/dev/null 2>&1; then
    echo "keyd note: add-apt-repository is unavailable; skipping keyd installation." >&2
    return 1
  fi

  sudo add-apt-repository -y ppa:keyd-team/ppa
  sudo apt-get update
  apt-cache show keyd >/dev/null 2>&1
}

mapfile -t packages < <(grep -vE '^\s*(#|$)' "$ROOT/install/apt-packages.txt")

sudo apt-get update
sudo apt-get install -y "${packages[@]}"
if install_keyd; then
  sudo apt-get install -y keyd
  sudo mkdir -p /etc/keyd
  sudo cp "$ROOT/linux/keyd/default.conf" /etc/keyd/default.conf
  sudo systemctl enable --now keyd
  sudo systemctl restart keyd
else
  echo "keyd note: package unavailable; install it manually on this machine." >&2
fi

if command -v pipx >/dev/null 2>&1; then
  pipx ensurepath >/dev/null 2>&1 || true
fi

if [ "${SKIP_USER_BINARIES:-0}" != "1" ]; then
  "$ROOT/install/setup-user-binaries.sh"
fi

echo "Ubuntu setup completed."
echo "Next steps:"
echo "  1. Run: $ROOT/install/link.sh"
echo "  2. Log out and back in if this is the first time enabling fcitx5 on this machine"
echo "  3. Optional: rerun $ROOT/install/setup-user-binaries.sh after updating pinned binary versions"
