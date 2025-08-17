return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Patch eslint_d to run from the file's directory (not global cwd)
    lint.linters.eslint_d = {
      cmd = "eslint_d",
      stdin = true,
      args = {
        "--stdin",
        "--stdin-filename",
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
      },
      stream = "both",
      cwd = function()
        -- Use directory of the current buffer as the working dir
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
      end,
      ignore_exitcode = true,
      parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
        source = "eslint_d",
        severity = vim.diagnostic.severity.WARN,
      }),
    }

    -- Associate filetypes with linters
    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      svelte = { "eslint_d" },
      python = { "pylint" },
    }

    -- Autocmd: lint on file events
    local lint_augroup = vim.api.nvim_create_augroup("LintAutoGroup", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    -- Manual keymap: <leader>l to lint current file
    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
