# dotfiles

这套目录用于统一管理开发环境配置，并在 Ubuntu / macOS 之间同步核心配置。

## 当前范围

- 同步 Emacs、Neovim、tmux、WezTerm、shell 配置
- 保留 Linux 侧的 fcitx5 / keyd 配置
- Linux 输入法目标行为：`keyboard-us` + `shuangpin(Xiaohe)`，`[` / `]` 翻页
- Linux 键位目标行为：`CapsLock -> Ctrl-Space`，用于切换 fcitx5 中英文
- 保留 macOS 侧 Karabiner 配置目录
- 提供基础安装脚本和软链接脚本

## 目录结构

```text
~/personal/dotfiles/
  common/
    emacs/
    nvim/
    tmux/
    wezterm/
    shell/
    scripts/
  linux/
    autostart/
    environment.d/
    fcitx5/
    keyd/
  mac/
    karabiner/
  install/
    Brewfile
    apt-packages.txt
    setup-mac.sh
    setup-ubuntu.sh
    link.sh
```

## 推荐初始化顺序

### 旧机器上先做一次

1. 进入目录：`cd ~/personal/dotfiles`
2. 初始化 Git 仓库并推送到私有远端

```bash
git init
git add .
git commit -m "init dotfiles"
# git remote add origin <your-private-repo>
# git push -u origin main
```

### 新机器通用顺序

1. 先安装并配置 Clash，确认浏览器和终端代理可用
2. 安装 Git
3. 同步本仓库到 `~/personal/dotfiles`
4. 运行平台安装脚本
5. 运行软链接脚本
6. 再补手动安装的桌面应用（如 Clash GUI、CCSwitch 等）

## Ubuntu 安装

### 1. 准备目录并同步仓库

```bash
mkdir -p ~/personal
git clone <your-private-repo> ~/personal/dotfiles
```

### 2. 安装基础依赖

```bash
cd ~/personal/dotfiles
./install/setup-ubuntu.sh
```

这个脚本当前会自动完成：

- 安装基础 apt 依赖
- 安装 `keyd` 并写入 `/etc/keyd/default.conf`
- 安装新版 `nvim` 到 `~/.local/bin/nvim`
- 安装 `wezterm` 到 `~/.local/bin/wezterm`
- 安装 `lazygit` 到 `~/.local/bin/lazygit`
- 安装 `Sarasa Mono SC` 到 `~/.local/share/fonts/sarasa`

如需只装 apt 依赖，不装用户态二进制：

```bash
SKIP_USER_BINARIES=1 ./install/setup-ubuntu.sh
```

### 3. 链接配置

```bash
./install/link.sh
```

### 4. Linux 额外处理

- `linux/fcitx5/` 会被链接到 `~/.config/fcitx5`
- `linux/environment.d/fcitx5.conf` 会被链接到 `~/.config/environment.d/fcitx5.conf`
- `linux/autostart/org.fcitx.Fcitx5.desktop` 会被链接到 `~/.config/autostart/org.fcitx.Fcitx5.desktop`
- 当前 fcitx5 约定为：`keyboard-us` + `shuangpin(Xiaohe)`，并使用 `[` / `]` 进行候选翻页
- 如果是 Ubuntu GNOME，`install/link.sh` 会尽量自动把桌面输入源收口为 `US` 并屏蔽 GNOME 自带的 `ibus` 用户服务
- `linux/keyd/default.conf` 当前把 `CapsLock` 映射成 `Ctrl-Space`，用于切换 fcitx5 中英文
- 改完 `environment.d` 后需要重新登录图形会话，或至少重启桌面会话，让输入法环境变量生效

```bash
./install/link.sh
```

## macOS 安装

### 1. 准备目录并同步仓库

```bash
mkdir -p ~/personal
git clone <your-private-repo> ~/personal/dotfiles
```

### 2. 安装基础依赖

先手动安装 Homebrew，然后执行：

```bash
cd ~/personal/dotfiles
./install/setup-mac.sh
```

### 3. 链接配置

```bash
./install/link.sh
```

### 4. macOS 额外处理

- `mac/karabiner/global-backspace.json` 可用于把 `Ctrl-h` 全局映射成退格
- Clash、CCSwitch 等桌面应用暂时手动安装
- Neovim 的 macOS 输入法自动切换当前默认使用 `macism`
- Emacs 的 macOS 输入法自动切换也复用 `macism`
- `macism` 安装：`brew tap laishulu/homebrew && brew install macism`
- `im-select` 安装：`brew tap daipeihust/tap && brew install im-select`
- 默认英文输入法为 `com.apple.keylayout.ABC`
- 默认中文输入法 ID 当前写死为 `com.apple.inputmethod.SCIM.Shuangpin`
- 如需固定插入模式输入法，可在 `common/nvim/lua/config/options.lua` 中设置 `vim.g.mac_insert_input_source`
- 如需修改 Emacs 的 macOS 输入法，可在 `common/emacs/init.el` 中调整 `my/mac-normal-input-source` 和 `my/mac-default-insert-input-source`

## 字体

当前 `common/wezterm/.wezterm.lua` 使用了：

- `Sarasa Mono SC`
- `Noto Color Emoji`

Ubuntu 下：

- `./install/setup-ubuntu.sh` 会安装 `Sarasa Mono SC`
- `./install/setup-ubuntu.sh` 会安装 `Noto Color Emoji`

## 软链接说明

`install/link.sh` 会把以下路径链接到用户目录：

- `common/nvim` -> `~/.config/nvim`
- `common/emacs/init.el` -> `~/.emacs.d/init.el`
- `common/tmux/.tmux.conf` -> `~/.tmux.conf`
- `common/wezterm/.wezterm.lua` -> `~/.wezterm.lua`
- `common/shell/.inputrc` -> `~/.inputrc`
- Linux 下额外链接 `linux/fcitx5` -> `~/.config/fcitx5`
- Linux 下额外链接 `linux/environment.d/fcitx5.conf` -> `~/.config/environment.d/fcitx5.conf`
- Linux 下额外链接 `linux/autostart/org.fcitx.Fcitx5.desktop` -> `~/.config/autostart/org.fcitx.Fcitx5.desktop`

如果目标路径已存在，脚本会先备份成 `*.bak.<timestamp>` 再建立新链接。

## 当前约定

- 工作目录保持统一：`~/personal`
- 项目仓库建议放在：`~/personal/project`
- org 文件建议放在：`~/personal/org`
- Emacs 的包目录、`custom.el`、历史文件等仍保留在各机器本地的 `~/.emacs.d/`，只同步 `init.el`

后续如果你要把更多系统配置纳入仓库，可以继续补：

- Ubuntu: `.xprofile`、`.xinputrc`
- macOS: 更多 Karabiner JSON、其他输入法切换配置
