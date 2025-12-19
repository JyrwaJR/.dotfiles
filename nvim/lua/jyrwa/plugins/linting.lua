return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    local path = require("lint.util").path

    -- Enhanced eslint_d with project-local detection
    lint.linters.eslint_d = {
      cmd = "eslint_d",
      stdin = true,
      args = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        local cwd = vim.fn.fnamemodify(bufname, ":p:h")
        local args = { "-f", "unix", "--stdin", "--stdin-filename", bufname }

        local configs = {
          path.join(cwd, ".eslintrc.js"),
          path.join(cwd, ".eslintrc.json"),
          path.join(cwd, ".eslintrc"),
          path.join(cwd, ".eslintrc.yaml"),
          path.join(cwd, ".eslintrc.yml"),
          path.join(cwd, "eslint.config.js"),
          path.join(cwd, "package.json"),
        }
        for _, config in ipairs(configs) do
          if vim.fn.filereadable(config) == 1 then
            table.insert(args, "--config")
            table.insert(args, config)
            break
          end
        end
        return args
      end,
      stream = "stdout",
      cwd = function()
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
      end,
      env = {
        ESLINT_USE_FLAT_CONFIG = "true",
      },
      ignore_exitcode = true,
      parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
        source = "eslint_d",
        severity = vim.diagnostic.severity.WARN,
      }),
    }

    -- React/Node.js focused linters (your stack)
    lint.linters_by_ft = {
      -- JavaScript/TypeScript/React/Next.js
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      -- Config files
      json = { "eslint_d" },
      jsonc = { "eslint_d" },
      -- Svelte/Vue (if used)
      svelte = { "eslint_d" },
      -- Python (fallback)
      python = { "pylint" },
      -- Prisma schema (uses ESLint if configured)
      prisma = { "eslint_d" },
    }

    -- Debounced linting (performance optimized)
    local lint_augroup = vim.api.nvim_create_augroup("LintAutoGroup", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        require("lint").try_lint()
      end,
    })

    -- Manual linting keymap
    vim.keymap.set("n", "<leader>l", function()
      require("lint").try_lint()
    end, { desc = "Trigger linting" })

    -- Clear diagnostics on InsertEnter (smooth UX)
    vim.api.nvim_create_autocmd("InsertEnter", {
      group = lint_augroup,
      callback = function()
        vim.diagnostic.setloclist({ open = false })
      end,
    })
  end,
}
