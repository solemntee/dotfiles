# mac

这里放 macOS 专用配置。

当前已预留：

- `karabiner/`: Karabiner 配置目录
- `karabiner/global-backspace.json`: `Ctrl-h` 全局映射成退格

Neovim 的 macOS 输入法自动切换已经接入 `common/nvim`，条件是：

- `vim.g.mac_auto_switch_input_method = true`
- 系统里能找到输入法切换命令
- 当前默认使用 `macism`
- Emacs 也复用同一套 `macism` 约定，配置在 `common/emacs/init.el`

默认配置：

- 输入法切换命令：`macism`
- 普通模式输入法：`com.apple.keylayout.ABC`
- 插入模式输入法：优先恢复上一次插入模式的输入法
- 如果你想固定插入模式输入法，可以设置 `vim.g.mac_insert_input_source`
- 如果你想指定命令，可以设置 `vim.g.mac_input_source_command`

Emacs 当前默认值：

- 普通模式输入法：`com.apple.keylayout.ABC`
- 插入模式默认输入法：`com.apple.inputmethod.SCIM.Shuangpin`
- 如需修改，编辑 `common/emacs/init.el` 中的：
  - `my/mac-normal-input-source`
  - `my/mac-default-insert-input-source`

查当前输入法 ID：

```bash
macism
```

后续可继续补：

- macOS defaults 脚本
- 其他输入法自动切换相关配置
