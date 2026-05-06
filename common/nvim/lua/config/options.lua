-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.autoread = true
vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-CursorInsert/lCursor,r-cr:hor20-CursorReplace/lCursor,o:hor50-Cursor/lCursor"

local is_remote = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil

if is_remote then
  -- SSH/mosh: OSC 52 协议直接同步剪贴板到本地终端
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
  vim.opt.clipboard = "unnamedplus"

  -- SSH 性能优化
  vim.opt.timeoutlen = 2000
  vim.opt.lazyredraw = true
  vim.opt.updatetime = 500
  vim.opt.synmaxcol = 200
  vim.g.snacks_animate = false
elseif vim.fn.executable("xclip") == 1 then
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
