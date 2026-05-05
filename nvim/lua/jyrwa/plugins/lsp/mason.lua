return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")
    local mason_tool_installer = require("mason-tool-installer")
    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })
    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "eslint_d", -- eslint linter
        "biome", -- js/ts formatter/linter alternative
        "actionlint", -- github actions linter
        "js-debug-adapter", -- dap adapter for node/typescript
      },
    })
  end,
}
