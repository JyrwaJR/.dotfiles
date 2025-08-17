return {
  "hrsh7th/nvim-cmp",
  event = { "BufReadPre", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    {
      "L3MON4D3/LuaSnip",
      version = "*",
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      completion = { completeopt = "menu,menuone,preview,noselect" },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      }),

      -- Simplified sorting (no need to dedup Codeium now)
      sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },

      -- Remaining sources
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
      }),

      formatting = {
        format = function(entry, vim_item)
          vim_item.dup = ({
            buffer = 0,
            path = 0,
            nvim_lsp = 0,
            luasnip = 0,
          })[entry.source.name] or 0
          return vim_item
        end,
      },
      -- formatting = {
      --   fields = { "kind", "abbr", "menu" },
      --   expandable_indicator = true,

      --   format = lspkind.cmp_format({
      --     mode = "symbol_text",
      --     maxwidth = 50,
      --     ellipsis_char = "...",
      --     menu = {
      --       nvim_lsp = "[LSP]",
      --       luasnip = "[Snip]",
      --       buffer = "[Buffer]",
      --       path = "[Path]",
      --     },
      --   }),
      -- },
    })

    -- Cmdline `/` setup
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline({
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      }),
      sources = { { name = "buffer" } },
    })

    -- Cmdline `:` setup
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline({
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
      }),
      sources = cmp.config.sources({ { name = "path" } }, {
        {
          name = "cmdline",
          option = { ignore_cmds = { "Man", "!" } },
        },
      }),
    })
  end,
}
