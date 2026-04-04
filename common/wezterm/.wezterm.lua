local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.use_ime = true
config.xim_im_name = "fcitx"
config.automatically_reload_config = true
config.color_scheme = "Catppuccin Latte"
config.font = wezterm.font_with_fallback({
  "Sarasa Mono SC",
  "Noto Color Emoji",
})
config.font_size = 16.0

return config
