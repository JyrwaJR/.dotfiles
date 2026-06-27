return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "folke/lazydev.nvim", opts = {} },
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    local mason_lspconfig = require("mason-lspconfig")
    local keymap = vim.keymap

    -- Enhanced LSP keymaps
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = false }
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
        opts.desc = "Code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
        opts.desc = "Hover documentation"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)
        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    local has_blink, blink = pcall(require, "blink.cmp")
    local capabilities = has_blink and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

    vim.diagnostic.config({
      virtual_text = false,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰠠 ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded" },
    })

    mason_lspconfig.setup({
      ensure_installed = {
        "ts_ls",
        "tailwindcss",
        "graphql",
        "emmet_ls",
        "lua_ls",
        "prismals",
        "cssls",
        "sqlls",
        "jsonls",
        "yamlls",
        "eslint",
        "html",
        "marksman",
      },
      automatic_installation = true,
    })

    local servers = {
      marksman = {},
      ts_ls = {
        init_options = {
          includeCompletionsWithInsertText = true,
          includeCompletionsForModuleExports = true,
        },
        settings = {
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
          },
          javascript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = { completeFunctionCalls = true },
          },
        },
      },
      graphql = {
        filetypes = { "graphql", "gql", "svelte", "javascript", "javascriptreact", "typescript", "typescriptreact" },
      },
      prismals = { filetypes = { "prisma", "schema" } },
      emmet_ls = {
        filetypes = {
          "html",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "css",
          "scss",
          "less",
          "svelte",
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            completion = { callSnippet = "Replace" },
            workspace = { checkThirdParty = false },
          },
        },
      },
      tailwindcss = {
        filetypes = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact" },
      },
      cssls = {},
      dartls = {},
      jsonls = {
        settings = {
          json = {
            schemas = {
              { fileMatch = { "package.json" }, url = "https://json.schemastore.org/package.json" },
              { fileMatch = { "app.json", "expo.json" }, url = "https://json.schemastore.org/expo.json" },
              { fileMatch = { "eas.json" }, url = "https://json.schemastore.org/eas.json" },
              {
                fileMatch = { "tsconfig.json", "tsconfig.*.json" },
                url = "https://json.schemastore.org/tsconfig.json",
              },
            },
          },
        },
      },
      yamlls = {
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              ["https://json.schemastore.org/github-action.json"] = "/.github/actions/*",
            },
          },
        },
      },
      eslint = {
        settings = {
          codeAction = { disableRuleComment = { enable = true, location = "separateLine" } },
          useFlatConfig = true,
        },
      },
      sqlls = {},
      html = {},
    }

    for name, config in pairs(servers) do
      config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
      -- Use the new 2026/Neovim 0.11+ API
      vim.lsp.config(name, config)
      vim.lsp.enable(name)
    end
  end,
}
