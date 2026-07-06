return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- mocha, macchiato, frappe, latte

      background = {
        light = "latte",
        dark = "mocha",
      },

      transparent_background = true,
      show_end_of_buffer = false,
      term_colors = true,

      dim_inactive = {
        enabled = false,
      },

      no_italic = false,
      no_bold = false,
      no_underline = false,

      styles = {
        comments = { "italic" },
        conditionals = { "italic" },

        functions = { "bold" },
        keywords = { "bold" },
        types = { "bold" },

        strings = { "italic" },

        loops = { "bold" },
        properties = { "italic" },
        variables = {},
        numbers = {},
        booleans = { "italic", "bold" },
        operators = {},
      },

      lsp_styles = {
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
          ok = { "italic" },
        },

        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
          ok = { "underline" },
        },

        inlay_hints = {
          background = true,
          illuminate = true,
        },
      },

      color_overrides = {
        macchiato = {
          base = "#1e2030",
          mantle = "#181926",
          crust = "#11111b",
        },
      },

      custom_highlights = function(colors)
        return {
          --------------------------------------------------
          -- Editor
          --------------------------------------------------
          Normal = { bg = "NONE" },
          NormalNC = { bg = "NONE" },

          CursorLine = {
            bg = colors.surface0,
          },

          CursorLineNr = {
            fg = colors.lavender,
            bold = true,
          },

          LineNr = {
            fg = colors.overlay0,
          },

          Visual = {
            bg = colors.surface1,
          },

          WinSeparator = {
            fg = colors.surface1,
          },

          --------------------------------------------------
          -- Syntax
          --------------------------------------------------
          Comment = {
            fg = colors.overlay1,
            italic = true,
          },

          Function = {
            fg = colors.mauve,
            bold = true,
          },

          Keyword = {
            fg = colors.pink,
            bold = true,
          },

          Type = {
            fg = colors.yellow,
            bold = true,
          },

          String = {
            fg = colors.green,
            italic = true,
          },

          --------------------------------------------------
          -- Floating Windows
          --------------------------------------------------
          NormalFloat = {
            bg = "NONE",
          },

          FloatBorder = {
            fg = colors.surface1,
            bg = "NONE",
          },

          --------------------------------------------------
          -- Completion Menu
          --------------------------------------------------
          Pmenu = {
            bg = colors.crust,
          },

          PmenuSel = {
            bg = colors.surface1,
          },

          --------------------------------------------------
          -- Telescope
          --------------------------------------------------
          TelescopeBorder = {
            fg = colors.surface1,
          },

          TelescopeTitle = {
            fg = colors.mauve,
            bold = true,
          },

          TelescopePromptTitle = {
            fg = colors.green,
            bold = true,
          },

          TelescopeResultsTitle = {
            fg = colors.blue,
            bold = true,
          },

          TelescopePreviewTitle = {
            fg = colors.yellow,
            bold = true,
          },

          --------------------------------------------------
          -- Diagnostics
          --------------------------------------------------
          DiagnosticError = {
            fg = colors.red,
          },

          DiagnosticWarn = {
            fg = colors.yellow,
          },

          DiagnosticInfo = {
            fg = colors.sky,
          },

          DiagnosticHint = {
            fg = colors.teal,
          },
        }
      end,

      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        noice = true,
        telescope = true,
        which_key = true,
        dressing = true,
        lazygit = true,

        indent_blankline = {
          enabled = true,
        },

        mini = {
          enabled = true,
        },

        leap = true,

        native_lsp = {
          enabled = true,

          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },

          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
      },
    })

    vim.cmd.colorscheme("catppuccin")
  end,
}
