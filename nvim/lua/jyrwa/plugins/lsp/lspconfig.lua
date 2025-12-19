return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-cmdline" },
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local keymap = vim.keymap

    -- Enhanced LSP keymaps (unchanged, works with 2025 standards)
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
        opts.desc = "Previous diagnostic"
        opts.desc = "Hover documentation"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)
        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    local capabilities = cmp_nvim_lsp.default_capabilities()
    vim.lsp.config("*", { capabilities = capabilities })

    vim.diagnostic.config({
      virtual_text = true,
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

    -- Mason setup with latest React/Node.js/Drizzle/Prisma servers [web:1][web:7][web:39]
    require("mason").setup()

    mason_lspconfig.setup({
      ensure_installed = {
        "ts_ls", -- TypeScript/JS/React/Next
        "tailwindcss", -- Tailwind in React
        "graphql", -- if you use GraphQL
        "emmet_ls", -- JSX/TSX snippets
        "lua_ls", -- Neovim config
        "prismals", -- Prisma schema
        "cssls",
      },
      automatic_installation = true,
    })

    vim.lsp.config("ts_ls", {
      settings = {
        typescript = { inlayHints = { includeInlayParameterNameHints = "all" } },
        javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
      },
      root_markers = { "bun.lockb" },
      on_attach = function(client, bufnr)
        client.handlers["textDocument/publishDiagnostics"] = function() end
        client.server_capabilities.documentFormattingProvider = false
        vim.api.nvim_create_autocmd("BufWritePost", {
          buffer = bufnr,
          callback = function(ctx)
            client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
          end,
        })
      end,
    })

    vim.lsp.config("graphql", {
      filetypes = { "graphql", "gql", "typescriptreact", "javascriptreact", "svelte" },
    })

    vim.lsp.config("prismals", {
      filetypes = { "prisma" },
    })

    vim.lsp.config("emmet_ls", {
      filetypes = {
        "html",
        "typescriptreact",
        "javascriptreact",
        "typescript",
        "javascript",
        "css",
        "scss",
        "less",
        "svelte",
      },
      settings = {
        emmet = {
          showAbbreviationsSuggestions = true,
          showExpandedAbbreviation = true,
        },
      },
    })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          completion = { callSnippet = "Replace" },
          workspace = {
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })

    vim.lsp.config("tailwindcss", {})
    vim.lsp.config("cssls", {})

    vim.lsp.enable({
      "ts_ls",
      "tailwindcss",
      "graphql",
      "emmet_ls",
      "lua_ls",
      "prismals",
      "cssls",
    })
  end,
}
