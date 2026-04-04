return {
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "org" })
      end
    end,
  },

  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    keys = {
      { "<leader>oa", "<cmd>Org agenda<cr>", desc = "Org Agenda" },
      { "<leader>oc", "<cmd>Org capture<cr>", desc = "Org Capture" },
    },
    config = function()
      require("orgmode").setup({
        org_agenda_files = { "~/personal/org/**/*" },
        org_default_notes_file = "~/personal/org/inbox.org",
        org_todo_keywords = {
          "TODO(t)",
          "NEXT(n)",
          "WAIT(w)",
          "BLOCKED(b)",
          "|",
          "DONE(d)",
          "CANCELLED(c)",
        },
        org_log_done = "time",
        org_log_into_drawer = "LOGBOOK",
        win_split_mode = "float",
        org_capture_templates = {
          t = {
            description = "Task",
            template = "* TODO %?\n[%<%Y-%m-%d %a %H:%M>]\n",
            target = "~/personal/org/inbox.org",
          },
          r = {
            description = "Roadmap",
            template = "* TODO [#B] %?\n[%<%Y-%m-%d %a %H:%M>]\n",
            target = "~/personal/org/roadmap.org",
          },
          p = {
            description = "Project task",
            template = "* TODO %?\n[%<%Y-%m-%d %a %H:%M>]\n",
            target = "~/personal/org/projects/personal.org",
          },
        },
      })

      vim.lsp.enable("org")
    end,
  },
}
