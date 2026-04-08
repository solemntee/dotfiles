#!/usr/bin/env bash
set -euo pipefail

NVIM_VERSION="v0.12.1"
NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage"
WEZTERM_VERSION="20240203-110809-5046fc22"
WEZTERM_URL="https://github.com/wez/wezterm/releases/download/${WEZTERM_VERSION}/WezTerm-${WEZTERM_VERSION}-Ubuntu20.04.AppImage"
LAZYGIT_VERSION="0.61.0"
LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_x86_64.tar.gz"
SARASA_VERSION="1.0.37"
SARASA_URL="https://github.com/be5invis/Sarasa-Gothic/releases/download/v${SARASA_VERSION}/Sarasa-TTC-${SARASA_VERSION}.zip"

BIN_DIR="${HOME}/.local/bin"
OPT_DIR="${HOME}/.local/opt"
APP_DIR="${HOME}/.local/share/applications"
FONT_DIR="${HOME}/.local/share/fonts/sarasa"
TMP_DIR="${TMPDIR:-/tmp}/dotfiles-user-binaries"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

backup_path() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    mv "$target" "${target}.bak.${TIMESTAMP}"
  fi
}

install_appimage() {
  local name="$1"
  local url="$2"
  local appimage="$TMP_DIR/${name}.appimage"
  local extract_dir="$TMP_DIR/${name}-extract"
  local target_dir="$OPT_DIR/$name"

  curl -fL "$url" -o "$appimage"
  chmod +x "$appimage"

  rm -rf "$extract_dir"
  mkdir -p "$extract_dir"
  (
    cd "$extract_dir"
    "$appimage" --appimage-extract >/dev/null
  )

  if [ -e "$target_dir" ] || [ -L "$target_dir" ]; then
    backup_path "$target_dir"
  fi
  mv "$extract_dir/squashfs-root" "$target_dir"
  ln -sfn "$target_dir/AppRun" "$BIN_DIR/$name"
}

install_tarball_binary() {
  local name="$1"
  local url="$2"
  local binary_name="$3"
  local archive="$TMP_DIR/${name}.tar.gz"
  local extract_dir="$TMP_DIR/${name}-extract"
  local target_dir="$OPT_DIR/$name"

  curl -fL "$url" -o "$archive"

  rm -rf "$extract_dir"
  mkdir -p "$extract_dir"
  tar -xzf "$archive" -C "$extract_dir"

  if [ -e "$target_dir" ] || [ -L "$target_dir" ]; then
    backup_path "$target_dir"
  fi
  mv "$extract_dir" "$target_dir"
  ln -sfn "$target_dir/$binary_name" "$BIN_DIR/$binary_name"
}

mkdir -p "$BIN_DIR" "$OPT_DIR" "$APP_DIR" "$FONT_DIR" "$TMP_DIR"

install_appimage "nvim" "$NVIM_URL"
install_appimage "wezterm" "$WEZTERM_URL"
install_tarball_binary "lazygit" "$LAZYGIT_URL" "lazygit"

cat > "$APP_DIR/wezterm.desktop" <<EOF
[Desktop Entry]
Name=WezTerm
Comment=Wez's Terminal Emulator
Keywords=shell;prompt;command;commandline;cmd;
Icon=$OPT_DIR/wezterm/usr/share/icons/hicolor/128x128/apps/org.wezfurlong.wezterm.png
StartupWMClass=org.wezfurlong.wezterm
TryExec=$BIN_DIR/wezterm
Exec=$BIN_DIR/wezterm start --cwd .
Type=Application
Categories=System;TerminalEmulator;Utility;
Terminal=false
EOF
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

curl -fL "$SARASA_URL" -o "$TMP_DIR/Sarasa-TTC-${SARASA_VERSION}.zip"
unzip -o "$TMP_DIR/Sarasa-TTC-${SARASA_VERSION}.zip" -d "$FONT_DIR" >/dev/null
fc-cache -f "$FONT_DIR" >/dev/null

echo "Installed user-space binaries:"
echo "  - nvim -> $BIN_DIR/nvim"
echo "  - wezterm -> $BIN_DIR/wezterm"
echo "  - lazygit -> $BIN_DIR/lazygit"
echo "Installed user fonts:"
echo "  - Sarasa Mono SC"
