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
