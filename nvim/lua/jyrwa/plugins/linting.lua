return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    local path = require("lint.util").path

    -- Enhanced eslint_d with project-root detection
    local function find_eslint_root()
      local buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
      local markers = {
        ".eslintrc.js", ".eslintrc.json", ".eslintrc",
        ".eslintrc.yaml", ".eslintrc.yml", "eslint.config.js",
        "package.json", ".git",
      }
      return vim.fs.root(buf_dir, markers)
    end

    lint.linters.eslint_d = {
      cmd = "eslint_d",
      stdin = true,
      args = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        local args = { "-f", "unix", "--stdin", "--stdin-filename", bufname }

        local root = find_eslint_root()
        if root then
          local configs = {
            path.join(root, ".eslintrc.js"),
            path.join(root, ".eslintrc.json"),
            path.join(root, ".eslintrc"),
            path.join(root, ".eslintrc.yaml"),
            path.join(root, ".eslintrc.yml"),
            path.join(root, "eslint.config.js"),
          }
          for _, config in ipairs(configs) do
            if vim.fn.filereadable(config) == 1 then
              table.insert(args, "--config")
              table.insert(args, config)
              break
            end
          end
        end
        return args
      end,
      stream = "stdout",
      cwd = find_eslint_root,
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
      -- javascript = { "eslint_d" },
      -- typescript = { "eslint_d" },
      -- javascriptreact = { "eslint_d" },
      -- typescriptreact = { "eslint_d" },
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
