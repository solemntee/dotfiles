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

configure_linux_desktop() {
  local desktop="${XDG_CURRENT_DESKTOP:-}"

  if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd \
      GTK_IM_MODULE=fcitx \
      QT_IM_MODULE=fcitx \
      XMODIFIERS=@im=fcitx \
      SDL_IM_MODULE=fcitx >/dev/null 2>&1 || true
  fi

  if printf '%s' "$desktop" | grep -qiE 'gnome|ubuntu' && command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]" >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.input-sources mru-sources "[('xkb', 'us')]" >/dev/null 2>&1 || true
    gsettings set org.gnome.desktop.input-sources current 0 >/dev/null 2>&1 || true
  fi

  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user mask --now org.freedesktop.IBus.session.GNOME.service >/dev/null 2>&1 || true
  fi

  if command -v fcitx5 >/dev/null 2>&1 && command -v fcitx5-remote >/dev/null 2>&1; then
    if ! fcitx5-remote --check >/dev/null 2>&1; then
      fcitx5 -d >/dev/null 2>&1 || true
    fi
  fi
}

link_path "$ROOT/common/nvim" "$HOME/.config/nvim"
link_path "$ROOT/common/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_path "$ROOT/common/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"
link_path "$ROOT/common/shell/.inputrc" "$HOME/.inputrc"

case "$(uname -s)" in
  Linux)
    link_path "$ROOT/linux/fcitx5" "$HOME/.config/fcitx5"
    link_path "$ROOT/linux/environment.d/fcitx5.conf" "$HOME/.config/environment.d/fcitx5.conf"
    link_path "$ROOT/linux/autostart/org.fcitx.Fcitx5.desktop" "$HOME/.config/autostart/org.fcitx.Fcitx5.desktop"
    configure_linux_desktop
    echo "Linux note: keyd should already be managed by install/setup-ubuntu.sh"
    ;;
  Darwin)
    echo "macOS note: import Karabiner rules from $ROOT/mac/karabiner when ready."
    ;;
  *)
    echo "Unknown platform. Only common links were created."
    ;;
esac
