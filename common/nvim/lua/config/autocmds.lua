-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("local_text_writing", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown", "org" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
})

local function normal_file_buffer(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr)
    and vim.bo[bufnr].buftype == ""
    and vim.bo[bufnr].modifiable
    and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

local function display_name(bufnr)
  return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")
end

local function set_external_conflict(bufnr, active)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  vim.b[bufnr].external_change_conflict = active or nil
  if not active then
    vim.b[bufnr].external_change_conflict_warned = nil
  end
end

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("local_auto_reload", { clear = true }),
  callback = function(args)
    if normal_file_buffer(args.buf) then
      vim.cmd("silent! checktime")
    end
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
  group = vim.api.nvim_create_augroup("local_auto_save", { clear = true }),
  callback = function(args)
    if normal_file_buffer(args.buf) and vim.bo[args.buf].modified then
      if vim.b[args.buf].external_change_conflict then
        if not vim.b[args.buf].external_change_conflict_warned then
          vim.b[args.buf].external_change_conflict_warned = true
          vim.schedule(function()
            vim.notify(
              ("Autosave paused for %s: the file changed outside Neovim and needs review/merge first."):format(
                display_name(args.buf)
              ),
              vim.log.levels.WARN,
              { title = "Neovim autosave paused" }
            )
          end)
        end
        return
      end
      vim.api.nvim_buf_call(args.buf, function()
        vim.cmd("update")
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShell", {
  group = vim.api.nvim_create_augroup("local_file_changed_prompt", { clear = true }),
  callback = function(args)
    if vim.v.fcs_reason == "conflict" then
      set_external_conflict(args.buf, true)
      vim.schedule(function()
        vim.notify(
          ("Detected external changes in %s while this buffer also has unsaved edits.\nReview or merge before saving."):format(
            display_name(args.buf)
          ),
          vim.log.levels.WARN,
          { title = "Neovim file conflict" }
        )
      end)
    end

    -- Preserve the built-in prompt so you can decide how to handle the conflict.
    vim.v.fcs_choice = "ask"
  end,
})

vim.api.nvim_create_autocmd({ "FileChangedShellPost", "BufWritePost", "BufReadPost" }, {
  group = vim.api.nvim_create_augroup("local_file_changed_cleanup", { clear = true }),
  callback = function(args)
    if vim.api.nvim_buf_is_valid(args.buf) and not vim.bo[args.buf].modified then
      set_external_conflict(args.buf, false)
    end
  end,
})

if vim.fn.executable("fcitx5-remote") == 1 then
  local group = vim.api.nvim_create_augroup("local_fcitx5_mode_switch", { clear = true })

  local function fcitx(args)
    vim.fn.system(vim.list_extend({ "fcitx5-remote" }, args))
  end

  local function to_english()
    fcitx({ "-s", "keyboard-us" })
  end

  local function to_shuangpin()
    fcitx({ "-o" })
    fcitx({ "-s", "shuangpin" })
  end

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = to_shuangpin,
  })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = to_english,
  })

  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = group,
    callback = to_english,
  })
end
