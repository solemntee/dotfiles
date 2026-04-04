return {
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      local writing_fts = {
        markdown = true,
        org = true,
        text = true,
        gitcommit = true,
        plaintex = true,
        typst = true,
      }

      opts.completion = opts.completion or {}
      opts.completion.menu = opts.completion.menu or {}
      opts.completion.documentation = opts.completion.documentation or {}
      opts.completion.menu.auto_show = function(ctx)
        local bufnr = ctx and ctx.bufnr or vim.api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].filetype
        return not writing_fts[ft]
      end
      opts.completion.documentation.auto_show = false

      opts.cmdline = opts.cmdline or {}
      opts.cmdline.enabled = true
      opts.cmdline.completion = opts.cmdline.completion or {}
      opts.cmdline.completion.menu = opts.cmdline.completion.menu or {}
      opts.cmdline.completion.menu.auto_show = function(ctx)
        return vim.fn.getcmdtype() == ":"
      end
      opts.cmdline.completion.ghost_text = { enabled = false }
    end,
  },
}
