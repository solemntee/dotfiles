# keyd

把 `default.conf` 手动复制到：

```text
/etc/keyd/default.conf
```

然后重启服务：

```bash
sudo systemctl enable --now keyd
sudo systemctl restart keyd
```
