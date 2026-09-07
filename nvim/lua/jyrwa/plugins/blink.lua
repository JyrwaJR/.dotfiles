return {
  "saghen/blink.cmp",
  dependencies = {
    { "rafamadriz/friendly-snippets", enabled = false },
  },
  version = "*",
  opts = {
    keymap = {
      preset = "default",
      ["<CR>"] = { "accept", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    enabled = function()
      return not vim.tbl_contains({ "typr" }, vim.bo.filetype)
        and vim.bo.buftype ~= "prompt"
        and vim.b.completion ~= false
    end,
    completion = {
      accept = {
        resolve_timeout_ms = 500,
      },
      menu = {
        border = "rounded",
        draw = {
          columns = { { "kind_icon" }, { "label", gap = 1 }, { "import_path" } },
          components = {
            label = {
              width = { max = 35 },
            },
            import_path = {
              width = { fill = true, max = 55 },
              text = function(ctx)
                if ctx.label_description ~= "" then
                  return ctx.label_description
                end

                return ""
              end,
              highlight = "BlinkCmpLabelDescription",
            },
          },
        },
      },
      documentation = {
        window = {
          border = "rounded",
        },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      per_filetype = {
        opencode_ask = { "lsp", "buffer" },
        sql = { "lsp", "snippets", "dadbod", "buffer" },
        mysql = { "lsp", "snippets", "dadbod", "buffer" },
        plsql = { "lsp", "snippets", "dadbod", "buffer" },
      },
      providers = {
        snippets = {
          opts = {
            friendly_snippets = false,
            search_paths = {
              vim.fn.stdpath("config") .. "/snippets",
              vim.fn.fnamemodify("~/.dotfiles/nvim", ":p") .. "snippets",
            },
          },
        },
        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
      },
    },
    signature = {
      enabled = true,
      window = { border = "rounded" },
    },
  },
  opts_extend = { "sources.default" },
}
