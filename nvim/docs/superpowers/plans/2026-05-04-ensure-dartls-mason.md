# Update Mason to ensure Dartls is installed Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure that the Dart Language Server (`dartls`) is automatically installed by `mason.nvim` and managed by `mason-lspconfig.nvim`.

**Architecture:** Modify the `ensure_installed` list in the `lspconfig.lua` plugin configuration file.

**Tech Stack:** Neovim, Lua, mason.nvim, mason-lspconfig.nvim.

---

### Task 1: Add 'dartls' to mason-lspconfig ensure_installed list

**Files:**
- Modify: `lua/jyrwa/plugins/lsp/lspconfig.lua:60-75`

- [ ] **Step 1: Modify the ensure_installed list**

```lua
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
        "dartls",
      },
      automatic_installation = true,
    })
```

- [ ] **Step 2: Verify the file content**

Run: `grep "dartls" lua/jyrwa/plugins/lsp/lspconfig.lua`
Expected: `        "dartls",` should be present in the file.

---

### Task 2: Commit changes

- [ ] **Step 1: Commit the change**

```bash
git add lua/jyrwa/plugins/lsp/lspconfig.lua
git commit -m "feat(lsp): ensure dartls is installed via mason"
```

- [ ] **Step 2: Verify the commit**

Run: `git status`
Expected: Working tree clean.
