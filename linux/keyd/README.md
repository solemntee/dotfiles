# keyd

把 `default.conf` 手动复制到：

```text
/etc/keyd/default.conf
```

当前配置语义：

- `capslock = C-space`
- 目标用途：把 `CapsLock` 当作 fcitx5 的中英文切换键
- 依赖：fcitx5 的触发键保持为 `Ctrl-Space`

然后重启服务：

```bash
sudo systemctl enable --now keyd
sudo systemctl restart keyd
```
