return {
  "MeanderingProgrammer/render-markdown.nvim",
  enabled = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- Syntax parsing (essential for accuracy)
    "echasnovski/mini.icons", -- For icons (can use nvim-web-devicons instead)
  },
  ft = { "markdown", "rmd", "org", "norg", "codecompanion" },
  opts = {
    enabled = true, -- Always render markdown by default

    heading = {
      sign = false, -- Disable icon highlight for headings (as you requested)
      -- icons = { ... }     -- Icons config if you enable sign
    },

    code = {
      sign = false, -- No icons for code fences
      width = "block", -- Display code block in fixed width, for readability
      right_pad = 1, -- Adds padding to code blocks
    },

    checkbox = {
      enabled = true,
      render_modes = false,
      bullet = false,
      right_pad = 6,
      unchecked = {
        icon = "[ ]",
        highlight = "RenderMarkdownUnchecked",
        scope_highlight = nil,
      },
      checked = {
        icon = "[x]",
        highlight = "RenderMarkdownChecked",
        scope_highlight = nil,
      },
      custom = {
        todo = { raw = "[-]", rendered = "[-]", highlight = "RenderMarkdownTodo", scope_highlight = nil },
      },
    },

    bullet = {
      enabled = true,
      render_modes = false,
      icons = { "●", "○", "◆", "◇" },
      ordered_icons = function(ctx)
        local value = vim.trim(ctx.value)
        local index = tonumber(value:sub(1, #value - 1))
        return ("%d."):format(index > 1 and index or ctx.index)
      end,
      left_pad = 0,
      right_pad = 1,
      highlight = "RenderMarkdownBullet",
    },
    indent = {
      enabled = false,
      render_modes = false,
      per_level = 2,
      skip_level = 1,
      skip_heading = false,
      icon = "▎",
      priority = 0,
      highlight = "RenderMarkdownIndent",
    },
    injections = {
      gitcommit = {
        enabled = true,
        query = [[
          ((message) @injection.content
            (#set! injection.combined)
            (#set! injection.include-children)
            (#set! injection.language "markdown"))
        ]],
      },
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
  end,
}
