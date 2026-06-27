return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },

  config = function()
    local conform = require("conform")

    -- ✅ DEFINE sqlfluff properly
    conform.formatters.sqlfluff = {
      command = "sqlfluff",
      args = { "fix", "--dialect", "postgres", "-" },
      stdin = true,
    }

    -- Ensure prettier resolves config from the project root
    conform.formatters.prettier = {
      cwd = function()
        local buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
        return vim.fs.root(buf_dir, {
          ".prettierrc", ".prettierrc.json", ".prettierrc.yaml",
          ".prettierrc.yml", ".prettierrc.js", "prettier.config.js",
          ".prettierrc.toml", "package.json", ".git",
        })
      end,
    }

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "isort", "black" },

        -- ✅ SQL support (IMPORTANT)
        sql = { "sqlfluff" },
        mysql = { "sqlfluff" },
        plsql = { "sqlfluff" },

        prisma = { "schema" },
      },

      format_on_save = {
        lsp_fallback = false, -- important
        async = false,
        timeout_ms = 1000,
      },
    })

    -- Format on InsertLeave for SQL buffers
    vim.api.nvim_create_autocmd("InsertLeave", {
      pattern = { "*.sql", "*.psql", "*.pgsql" },
      callback = function()
        if vim.bo.modified then
          conform.format({
            lsp_fallback = false,
            async = false,
            timeout_ms = 1000,
          })
        end
      end,
    })

    -- Manual format key
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = false,
        async = true,
        timeout_ms = 2000,
      })
    end, { desc = "Format file or range" })
  end,
}
