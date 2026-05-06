return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "latte",
      custom_highlights = function(c)
        local levels = {
          [1] = c.blue,
          [2] = c.peach,
          [3] = c.green,
          [4] = c.teal,
          [5] = c.mauve,
          [6] = c.pink,
        }

        local blocks = {
          [1] = "#dce8ff",
          [2] = "#ffe7d3",
          [3] = "#deefd8",
          [4] = "#d7eff0",
          [5] = "#ece4ff",
          [6] = "#f9e1ee",
        }

        local hl = {
          Cursor = { fg = c.base, bg = c.red },
          CursorIM = { fg = c.base, bg = c.red },
          CursorInsert = { fg = c.base, bg = c.red },
          CursorReplace = { fg = c.base, bg = c.maroon },
          lCursor = { fg = c.base, bg = c.red },
          markdownHeadingDelimiter = { fg = c.overlay1, bold = true },
          TermCursor = { fg = c.base, bg = c.red },
        }

        for level, color in pairs(levels) do
          local bg = blocks[level]
          hl["markdownH" .. level] = { fg = color, bg = bg, bold = true }
          hl["@markup.heading." .. level .. ".markdown"] = { fg = color, bg = bg, bold = true }
          hl["RenderMarkdownH" .. level] = { fg = color, bold = true }
          hl["RenderMarkdownH" .. level .. "Bg"] = { bg = bg }
        end

        return hl
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-latte",
    },
  },
}
