-- return {
--   "folke/tokyonight.nvim",
--   priority = 1000,
--   config = function()
--     local transparent = true -- set to true if you would like to enable transparency
--     local bg = "#011628"
--     local bg_dark = "#011423"
--     local bg_highlight = "#143652"
--     local bg_search = "#0A64AC"
--     local bg_visual = "#275378"
--     local fg = "#CBE0F0"
--     local fg_dark = "#B4D0E9"
--     local fg_gutter = "#627E97"
--     local border = "#547998"
--
--     require("tokyonight").setup({
--       style = "night",
--       transparent = transparent,
--       styles = {
--         sidebars = transparent and "transparent" or "dark",
--         floats = transparent and "transparent" or "dark",
--       },
--       on_colors = function(colors)
--         colors.bg = bg
--         colors.bg_dark = transparent and colors.none or bg_dark
--         colors.bg_float = transparent and colors.none or bg_dark
--         colors.bg_highlight = bg_highlight
--         colors.bg_popup = bg_dark
--         colors.bg_search = bg_search
--         colors.bg_sidebar = transparent and colors.none or bg_dark
--         colors.bg_statusline = transparent and colors.none or bg_dark
--         colors.bg_visual = bg_visual
--         colors.border = border
--         colors.fg = fg
--         colors.fg_dark = fg_dark
--         colors.fg_float = fg
--         colors.fg_gutter = fg_gutter
--         colors.fg_sidebar = fg_dark
--       end,
--     })
--
--     vim.cmd("colorscheme tokyonight")
--   end,
-- }
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "macchiato", -- latte, frappe, macchiato, mocha
      background = {
        light = "macchiato",
        dark = "macchiato",
      },
      transparent_background = true, -- Modern transparent background
      show_end_of_buffer = false, -- Hide ~ at the end of the buffer
      term_colors = true,
      dim_inactive = {
        enabled = true, -- Helps focus on active window
        shade = "dark",
        percentage = 0.3,
      },
      no_italic = true, -- Disable italics for better readability
      no_bold = true, -- Allow bold for key elements
      no_underline = true,

      styles = {
        comments = { "italic" }, -- Keep comments slightly italic for readability
        conditionals = { "bold", "italic" }, -- Make conditionals more prominent
        loops = { "bold" },
        functions = { "bold", "italic" },
        keywords = { "bold" }, -- Enhance keywords for clarity
        strings = { "italic", "bold" },
        variables = { "italic" }, -- Differentiate variables
        numbers = { "bold" },
        booleans = { "bold" },
        properties = {},
        types = { "bold" },
        operators = {},
      },

      -- Override specific colors for a more vibrant experience
      color_overrides = {
        mocha = {
          base = "#1e1e2e", -- Darker background for less eye strain
          mantle = "#181825",
          crust = "#11111b",
        },
      },

      -- Custom highlights for better visibility
      custom_highlights = {
        Comment = { fg = "#8aadf4", style = { "italic" } }, -- Light blue comments
        Function = { fg = "#f5e0dc", style = { "bold" } },
        Keyword = { fg = "#cba6f7", style = { "bold" } },
        String = { fg = "#a6e3a1" },
        Variable = { fg = "#fab387", style = { "italic" } },
        Type = { fg = "#f9e2af", style = { "bold" } },
      },

      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        noice = true,
        leap = true,
        mini = {
          enabled = false,
          indentscope_color = "",
        },
      },
    })

    -- Set colorscheme
    vim.cmd.colorscheme("catppuccin")
  end,
}
