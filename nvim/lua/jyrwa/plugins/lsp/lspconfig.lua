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
        opts.desc = "Refresh diagnostics"
        keymap.set("n", "<leader>lR", "<cmd>LspRefresh<CR>", opts)
        opts.desc = "Show LSP status"
        keymap.set("n", "<leader>ls", "<cmd>LspInfo<CR>", opts)
      end,
    })

    -- Diagnostic refresh: force LSP server to re-send diagnostics for current buffer.
    -- Use when diagnostics go stale (a known ts_ls issue).
    vim.api.nvim_create_user_command("LspRefresh", function()
      local buf = vim.api.nvim_get_current_buf()
      vim.diagnostic.reset(buf)

      -- Request fresh diagnostics from all attached clients that support pull diagnostics
      vim.lsp.buf_request(buf, "textDocument/diagnostic", {
        textDocument = { uri = vim.uri_from_bufnr(buf) },
        identifier = "default",
      }, function(err, result, ctx)
        if err or not result then
          return
        end
        -- Feed the response back through the diagnostic handler
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
          client.pull_diagnostic_handler(err, result, ctx, nil)
        end
      end)
    end, { desc = "Force-refresh LSP diagnostics for the current buffer" })

    local has_blink, blink = pcall(require, "blink.cmp")
    local capabilities = has_blink and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

    vim.diagnostic.config({
      virtual_text = false,
      virtual_lines = false, -- explicit default; toggle with <leader>ll
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
      },
      automatic_installation = true,
    })

    local servers = {
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
      -- Use the new Neovim 0.11+ API; wrap in pcall so one bad server doesn't break the rest
      local ok_conf, err_conf = pcall(vim.lsp.config, name, config)
      if not ok_conf then
        vim.notify(string.format("LSP config failed for %s: %s", name, err_conf), vim.log.levels.WARN)
      else
        local ok_enable, err_enable = pcall(vim.lsp.enable, name)
        if not ok_enable then
          vim.notify(string.format("LSP enable failed for %s: %s", name, err_enable), vim.log.levels.WARN)
        end
      end
    end
  end,
}
