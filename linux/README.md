# linux

这里放 Ubuntu / Linux 专用配置。

当前已包含：

- `autostart/org.fcitx.Fcitx5.desktop`: GNOME/KDE 登录时自动启动 fcitx5
- `environment.d/fcitx5.conf`: fcitx5 所需环境变量
- `fcitx5/`: 用户态 fcitx5 配置
- `fcitx5/profile`: 当前约定为 `keyboard-us` + `shuangpin(Xiaohe)`
- `fcitx5/conf/pinyin.conf`: 已包含 `[` / `]` 翻页
- `keyd/default.conf`: keyd 草稿整理后的默认配置
- `keyd/default.conf`: 当前把 `CapsLock` 映射为 `Ctrl-Space`，用于切换 fcitx5 中英文
- Ubuntu GNOME: 桌面输入源应只保留 `US`，避免同时保留 `ibus/libpinyin`
- Ubuntu GNOME: 建议执行 `systemctl --user mask --now org.freedesktop.IBus.session.GNOME.service`

后续可继续补：

- `.xprofile`
- `.xinputrc`
