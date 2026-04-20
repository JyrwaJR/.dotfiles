return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "macchiato", -- latte, frappe, macchiato, mocha
      background = {
        light = "latte",
        dark = "macchiato",
      },
      transparent_background = true,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.10,
      },
      no_italic = false,
      no_bold = false,
      no_underline = false,

      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = { "bold" },
        functions = { "bold" },
        keywords = { "bold" },
        strings = { "italic" },
        variables = {},
        numbers = {},
        booleans = { "italic" },
        properties = { "italic" },
        types = {},
        operators = {},
      },
      lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
          ok = { "italic" },
        },
        underlines = {
          errors = { "bold" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
          ok = { "italic" },
        },
        inlay_hints = {
          background = true,
          illuminate = true,
        },
      },
      -- Override specific colors for a more vibrant experience
      color_overrides = {
        mocha = {
          base = "#1e1e2e", -- Darker background for less eye strain
          mantle = "#181825",
          crust = "#11111b",
        },
      },

      custom_highlights = function(colors)
        return {
          Comment = { fg = colors.lavender, style = { "italic" } },
          Function = { fg = colors.mauve, style = { "bold" } },
          Keyword = { fg = colors.pink, style = { "italic" } },
          String = { fg = colors.green },
          Variable = { fg = colors.peach },
          Type = { fg = colors.yellow, style = { "bold" } },
          NormalFloat = { bg = "NONE" },
          FloatBorder = { fg = colors.surface1 },
          WinSeparator = { fg = colors.surface1 },
          CursorLine = { bg = colors.surface0 },
          Visual = { bg = colors.surface1 },
          LineNr = { fg = colors.overlay0 },
          Pmenu = { bg = colors.crust },
          PmenuSel = { bg = colors.surface1 },
          TelescopeTitle = { fg = colors.lavender, style = { "bold" } },
          TelescopeBorder = { fg = colors.surface1 },
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
        indent_blankline = { enabled = true },
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
        leap = true,
        mini = { enabled = true },
        dressing = true,
        lazygit = true,
      },
    })

    -- Set colorscheme
    vim.cmd.colorscheme("catppuccin")
  end,
}
