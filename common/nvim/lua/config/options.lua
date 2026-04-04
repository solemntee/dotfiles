-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.autoread = true
if vim.fn.executable("xclip") == 1 then
  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = "xclip -in -selection clipboard",
      ["*"] = "xclip -in -selection primary",
    },
    paste = {
      ["+"] = "xclip -out -selection clipboard",
      ["*"] = "xclip -out -selection primary",
    },
    cache_enabled = 0,
  }
  vim.opt.clipboard = "unnamedplus"
else
  vim.opt.clipboard = ""
end

if vim.fn.has("mac") == 1 then
  if vim.g.mac_auto_switch_input_method == nil then
    vim.g.mac_auto_switch_input_method = true
  end
  if vim.g.mac_input_source_command == nil then
    vim.g.mac_input_source_command = "macism"
  end
  if vim.g.mac_normal_input_source == nil then
    vim.g.mac_normal_input_source = "com.apple.keylayout.ABC"
  end
  if vim.g.mac_insert_input_source == nil then
    vim.g.mac_insert_input_source = "com.apple.inputmethod.SCIM.Shuangpin"
  end
end
