#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

backup_path() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    local backup="${target}.bak.${TIMESTAMP}"
    mv "$target" "$backup"
    echo "Backed up $target -> $backup"
  fi
}

link_path() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    local current
    current="$(readlink "$target")"
    if [ "$current" = "$source" ]; then
      echo "Already linked: $target"
      return
    fi
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    backup_path "$target"
  fi

  ln -s "$source" "$target"
  echo "Linked $target -> $source"
}

link_path "$ROOT/common/nvim" "$HOME/.config/nvim"
link_path "$ROOT/common/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_path "$ROOT/common/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"
link_path "$ROOT/common/shell/.inputrc" "$HOME/.inputrc"

case "$(uname -s)" in
  Linux)
    link_path "$ROOT/linux/fcitx5" "$HOME/.config/fcitx5"
    echo "Linux note: keyd still needs manual copy to /etc/keyd/default.conf"
    ;;
  Darwin)
    echo "macOS note: karabiner files are not linked yet; use $ROOT/mac/karabiner when ready."
    ;;
  *)
    echo "Unknown platform. Only common links were created."
    ;;
esac
