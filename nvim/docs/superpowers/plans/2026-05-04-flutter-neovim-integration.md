# Flutter Neovim Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate Flutter/Dart support into the existing modular Neovim configuration (`jyrwa`) with `blink.cmp` support and dedicated keymaps.

**Architecture:** Add a new plugin module for `flutter-tools.nvim`, update Treesitter for Dart syntax, and ensure `dartls` is managed by Mason.

**Tech Stack:** Neovim (Lua), lazy.nvim, flutter-tools.nvim, nvim-lspconfig, mason.nvim, nvim-treesitter, blink.cmp.

---

### Task 1: Update Treesitter for Dart Support

**Files:**
- Modify: `lua/jyrwa/plugins/treesitter.lua`

- [ ] **Step 1: Add 'dart' to Treesitter ensure_installed list**
```lua
-- Add "dart" to the ensure_installed table in lua/jyrwa/plugins/treesitter.lua
      ensure_installed = {
        "javascript",
        "typescript",
        "tsx",
        "sql",
        "yaml",
        "css",
        "prisma",
        "markdown",
        "markdown_inline",
        "bash",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "http",
        "json",
        "vimdoc",
        "c",
        "dart", -- Added dart
      },
```

- [ ] **Step 2: Commit changes**
```bash
git add lua/jyrwa/plugins/treesitter.lua
git commit -m "feat(treesitter): add dart support"
```

---

### Task 2: Configure Flutter Tools Plugin

**Files:**
- Create: `lua/jyrwa/plugins/flutter.lua`

- [ ] **Step 1: Create Flutter plugin configuration**
```lua
return {
  "akinsho/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim", -- optional for better UI
  },
  config = function()
    require("flutter-tools").setup({
      ui = {
        border = "rounded",
        notification_style = "native",
      },
      decorations = {
        statusline = {
          device = true,
          app_version = true,
        },
      },
      widget_guides = {
        enabled = true,
      },
      lsp = {
        color_indicator = true,
        on_attach = function(client, bufnr)
          local keymap = vim.keymap
          local opts = { buffer = bufnr, silent = true }

          -- Flutter specific keymaps
          opts.desc = "Flutter Run"
          keymap.set("n", "<leader>Fr", "<cmd>FlutterRun<CR>", opts)
          opts.desc = "Flutter Hot Reload"
          keymap.set("n", "<leader>Fh", "<cmd>FlutterHotReload<CR>", opts)
          opts.desc = "Flutter Hot Restart"
          keymap.set("n", "<leader>FR", "<cmd>FlutterHotRestart<CR>", opts)
        end,
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          renameFilesWithClasses = "always",
          enableSnippets = true,
        },
      },
    })
  end,
}
```

- [ ] **Step 2: Commit changes**
```bash
git add lua/jyrwa/plugins/flutter.lua
git commit -m "feat(flutter): add flutter-tools.nvim configuration"
```

---

### Task 3: Update Mason to ensure Dartls is installed

**Files:**
- Modify: `lua/jyrwa/plugins/lsp/lspconfig.lua`

- [ ] **Step 1: Add 'dartls' to mason-lspconfig ensure_installed list**
```lua
-- Modify ensure_installed in lua/jyrwa/plugins/lsp/lspconfig.lua
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
        "dartls", -- Added dartls
      },
      automatic_installation = true,
    })
```

- [ ] **Step 2: Commit changes**
```bash
git add lua/jyrwa/plugins/lsp/lspconfig.lua
git commit -m "feat(lsp): ensure dartls is installed via mason"
```

---

### Task 4: Verification

- [ ] **Step 1: Run Neovim and check for errors**
Run: `nvim`
Expected: No errors on startup.

- [ ] **Step 2: Check Mason status**
Run: `:Mason`
Expected: `dartls` should be installed or installing.

- [ ] **Step 3: Check Treesitter status**
Run: `:checkhealth nvim-treesitter`
Expected: `dart` parser is installed.
