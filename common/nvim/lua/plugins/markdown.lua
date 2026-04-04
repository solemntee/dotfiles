return {
  {
    "preservim/vim-markdown",
    ft = { "markdown" },
    init = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 0
      vim.g.vim_markdown_conceal_code_blocks = 0
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_toc_autofit = 1
    end,
    config = function()
      local function header_level(bufnr, lnum)
        local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
        local atx = line:match("^(#+)%s+")
        if atx then
          return #atx
        end

        local next_line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ""
        if next_line:match("^=+%s*$") then
          return 1
        elseif next_line:match("^-+%s*$") then
          return 2
        end
        return 0
      end

      local function current_heading_lnum(bufnr, lnum)
        for i = lnum, 1, -1 do
          if header_level(bufnr, i) > 0 then
            return i
          end
        end
        return nil
      end

      local function subtree_end(bufnr, start_lnum)
        local level = header_level(bufnr, start_lnum)
        local last = vim.api.nvim_buf_line_count(bufnr)
        for lnum = start_lnum + 1, last do
          local other_level = header_level(bufnr, lnum)
          if other_level > 0 and other_level <= level then
            return lnum - 1
          end
        end
        return last
      end

      local function immediate_child_headings(bufnr, start_lnum, end_lnum)
        local level = header_level(bufnr, start_lnum)
        local children = {}
        for lnum = start_lnum + 1, end_lnum do
          if header_level(bufnr, lnum) == level + 1 then
            table.insert(children, lnum)
          end
        end
        return children
      end

      local function has_closed_immediate_child(children)
        for _, lnum in ipairs(children) do
          if vim.fn.foldclosed(lnum) ~= -1 then
            return true
          end
        end
        return false
      end

      local function close_immediate_children(children)
        for _, lnum in ipairs(children) do
          vim.cmd(("%dfoldclose"):format(lnum))
        end
      end

      local function open_all_descendants(bufnr, start_lnum, end_lnum)
        for lnum = start_lnum + 1, end_lnum do
          if header_level(bufnr, lnum) > 0 then
            vim.cmd(("%dfoldopen!"):format(lnum))
          end
        end
      end

      _G.local_markdown_heading_foldexpr = function(lnum)
        local bufnr = vim.api.nvim_get_current_buf()
        local level = header_level(bufnr, lnum)
        if level > 0 then
          return ">" .. level
        end

        local heading_lnum = current_heading_lnum(bufnr, lnum)
        if not heading_lnum then
          return 0
        end
        return header_level(bufnr, heading_lnum)
      end

      local group = vim.api.nvim_create_augroup("local_markdown_org_like", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "markdown",
        callback = function(event)
          local nav_opts = { buffer = event.buf, silent = true, remap = false }
          local opts = { buffer = event.buf, silent = true, remap = false }
          vim.b[event.buf].markdown_heading_cycle = {}
          local function cycle_current_heading_fold()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local heading_lnum = current_heading_lnum(event.buf, cursor[1])
            if not heading_lnum then
              return
            end
            vim.api.nvim_win_set_cursor(0, { heading_lnum, 0 })
            local end_lnum = subtree_end(event.buf, heading_lnum)
            local children = immediate_child_headings(event.buf, heading_lnum, end_lnum)
            local states = vim.b[event.buf].markdown_heading_cycle
            local state = states[heading_lnum]

            if not state then
              if vim.fn.foldclosed(heading_lnum) ~= -1 then
                state = 1
              elseif has_closed_immediate_child(children) then
                state = 2
              else
                state = 3
              end
            end

            if #children == 0 then
              if state == 1 then
                vim.cmd(("%dfoldopen!"):format(heading_lnum))
                state = 3
              else
                vim.cmd(("%dfoldclose"):format(heading_lnum))
                state = 1
              end
            else
              if state == 1 then
                vim.cmd(("%dfoldopen"):format(heading_lnum))
                close_immediate_children(children)
                state = 2
              elseif state == 2 then
                vim.cmd(("%dfoldopen"):format(heading_lnum))
                open_all_descendants(event.buf, heading_lnum, end_lnum)
                state = 3
              else
                vim.cmd(("%dfoldclose"):format(heading_lnum))
                state = 1
              end
            end

            states[heading_lnum] = state
            vim.api.nvim_win_set_cursor(0, { heading_lnum, 0 })
          end

          local function cycle_all_folds()
            local state = vim.b[event.buf].markdown_fold_cycle or 3
            if state == 1 then
              vim.wo.foldlevel = 2
              vim.cmd.normal({ args = { "zx" }, bang = true })
              vim.b[event.buf].markdown_fold_cycle = 2
            elseif state == 2 then
              vim.wo.foldlevel = 99
              vim.cmd.normal({ args = { "zR" }, bang = true })
              vim.b[event.buf].markdown_fold_cycle = 3
            else
              vim.wo.foldlevel = 1
              vim.cmd.normal({ args = { "zx" }, bang = true })
              vim.b[event.buf].markdown_fold_cycle = 1
            end
            vim.b[event.buf].markdown_heading_cycle = {}
          end

          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "v:lua.local_markdown_heading_foldexpr(v:lnum)"
          vim.opt_local.foldenable = true
          vim.opt_local.foldlevel = 99

          -- Match orgmode heading navigation muscle memory.
          vim.keymap.set("n", "}", "<Plug>Markdown_MoveToNextHeader", vim.tbl_extend("force", nav_opts, { desc = "Next heading" }))
          vim.keymap.set("n", "{", "<Plug>Markdown_MoveToPreviousHeader", vim.tbl_extend("force", nav_opts, { desc = "Previous heading" }))
          vim.keymap.set("n", "]]", "<Plug>Markdown_MoveToNextSiblingHeader", vim.tbl_extend("force", nav_opts, { desc = "Next heading same level" }))
          vim.keymap.set("n", "[[", "<Plug>Markdown_MoveToPreviousSiblingHeader", vim.tbl_extend("force", nav_opts, { desc = "Previous heading same level" }))
          vim.keymap.set("n", "g{", "<Plug>Markdown_MoveToParentHeader", vim.tbl_extend("force", nav_opts, { desc = "Parent heading" }))

          vim.keymap.set("n", "<Tab>", cycle_current_heading_fold, vim.tbl_extend("force", opts, { remap = false, desc = "Cycle current heading fold" }))
          vim.keymap.set("n", "<S-Tab>", cycle_all_folds, vim.tbl_extend("force", opts, { remap = false, desc = "Cycle all folds" }))
        end,
      })
    end,
  },
}
