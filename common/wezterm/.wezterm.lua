local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.use_ime = true
config.xim_im_name = "fcitx"
config.automatically_reload_config = true
config.color_scheme = "One Dark (Gogh)"
config.colors = {
  foreground = "#d7dae0",
  background = "#282c34",
  cursor_bg = "#d20f39",
  cursor_fg = "#eff1f5",
}
config.font = wezterm.font_with_fallback({
  "Sarasa Mono SC",
  "Noto Color Emoji",
})
config.font_size = 16.0
config.keys = {
  {
    key = "Enter",
    mods = "ALT",
    action = wezterm.action.DisableDefaultAssignment,
  },
}

return config
