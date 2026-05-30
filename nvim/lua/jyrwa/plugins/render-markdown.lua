return {
  "MeanderingProgrammer/render-markdown.nvim",
  enabled = true,
  dependencies = {
    "nvim-treesitter/nvim-treesitter", -- Syntax parsing (essential for accuracy)
    "echasnovski/mini.icons", -- For icons (can use nvim-web-devicons instead)
  },
  ft = { "markdown", "rmd", "org", "norg", "codecompanion" },
  keys = {
    { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Render" },
  },
  opts = {
    enabled = false,

    heading = {
      sign = false,
      width = "block",
      position = "inline",
    },

    code = {
      sign = false,
      width = "block",
      right_pad = 2,
    },

    checkbox = {
      enabled = true,
      render_modes = false,
      bullet = false,
      right_pad = 6,
      unchecked = {
        icon = "☐",
        highlight = "RenderMarkdownUnchecked",
        scope_highlight = nil,
      },
      checked = {
        icon = "☑",
        highlight = "RenderMarkdownChecked",
        scope_highlight = nil,
      },
      custom = {
        todo = { raw = "[-]", rendered = "❍", highlight = "RenderMarkdownTodo", scope_highlight = nil },
      },
    },

    bullet = {
      enabled = true,
      render_modes = false,
      icons = { "•", "◦", "▪", "▫" },
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
      enabled = true,
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
    local ok, catppuccin = pcall(require, "catppuccin.palettes")
    if ok then
      local p = catppuccin.get_palette("mocha")
      vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { fg = p.overlay0 })
      vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = p.green })
      vim.api.nvim_set_hl(0, "RenderMarkdownTodo", { fg = p.yellow })
      vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = p.lavender })
      vim.api.nvim_set_hl(0, "RenderMarkdownIndent", { fg = p.surface1 })
      vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = p.surface0 })
      vim.api.nvim_set_hl(0, "RenderMarkdownHeading", { fg = p.mauve })
    end
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "rmd" },
      callback = function(args)
        vim.opt_local.number = true
        vim.opt_local.relativenumber = true
      end,
    })
  end,
}
