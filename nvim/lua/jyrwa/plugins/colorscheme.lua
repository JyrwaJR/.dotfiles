return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      background = {
        light = "mocha",
        dark = "mocha",
      },
      transparent_background = true, -- Modern transparent background
      show_end_of_buffer = false, -- Hide ~ at the end of the buffer
      term_colors = true, -- Use terminal colors
      dim_inactive = {
        enabled = false, -- Helps focus on active window
        shade = "dark",
        percentage = 0.15,
      },
      no_italic = true, -- Disable italics for better readability
      no_bold = true, -- Allow bold for key elements
      no_underline = true,

      styles = {
        comments = { "italic", "bold" }, -- Keep comments slightly italic for readability
        conditionals = { "bold", "italic" }, -- Make conditionals more prominent
        loops = { "bold", "italic" },
        functions = { "bold", "italic" },
        keywords = { "bold" }, -- Enhance keywords for clarity
        strings = { "italic", "bold" },
        variables = { "italic" }, -- Differentiate variables
        numbers = { "bold" },
        booleans = { "bold" },
        properties = {},
        types = { "bold" },
        operators = {
          "bold",
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

      -- Custom highlights for better visibility
      custom_highlights = {
        --   Comment = { fg = "#8aadf4", style = { "italic" } }, -- Light blue comments
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
