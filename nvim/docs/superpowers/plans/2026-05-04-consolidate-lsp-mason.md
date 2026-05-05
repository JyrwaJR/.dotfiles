# Consolidate Mason LSP Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Consolidate `mason-lspconfig` configuration into a single file and ensure `dartls` is included.

**Architecture:** Remove redundant `mason_lspconfig.setup` from `lua/jyrwa/plugins/lsp/mason.lua` and merge all servers into `lua/jyrwa/plugins/lsp/lspconfig.lua`.

**Tech Stack:** Neovim, Lua, Mason, nvim-lspconfig

---

### Task 1: Consolidate `ensure_installed` list in `lspconfig.lua`

**Files:**
- Modify: `lua/jyrwa/plugins/lsp/lspconfig.lua`

- [ ] **Step 1: Update the `ensure_installed` list**
Merge `"html"` from `mason.lua` into the list in `lspconfig.lua`. `dartls` is already present.

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
        "html",
      },
      automatic_installation = true,
    })
```

- [ ] **Step 2: Add `html` to the `servers` table for initialization**
Ensure `html` is handled by the setup loop.

```lua
      eslint = {
        settings = {
          codeAction = { disableRuleComment = { enable = true, location = "separateLine" } },
          useFlatConfig = true,
        },
      },
      sqlls = {},
      html = {},
    }
```

- [ ] **Step 3: Commit the changes**

```bash
git add lua/jyrwa/plugins/lsp/lspconfig.lua
git commit -m "feat(lsp): consolidate ensure_installed list in lspconfig"
```

---

### Task 2: Remove redundant configuration from `mason.lua`

**Files:**
- Modify: `lua/jyrwa/plugins/lsp/mason.lua`

- [ ] **Step 1: Remove `mason_lspconfig.setup` call**
Delete the redundant setup block.

```lua
<<<<
    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "graphql",
        "emmet_ls",
        "prismals",
        "jsonls",
        "yamlls",
        "eslint",
        "sqlls",
      },
    })
====
>>>>
```

- [ ] **Step 2: Remove unused variable `mason_lspconfig`**
Cleanup the require call if no longer needed in this scope.

```lua
<<<<
    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")
====
>>>>
```

- [ ] **Step 3: Commit the changes**

```bash
git add lua/jyrwa/plugins/lsp/mason.lua
git commit -m "fix(lsp): remove redundant mason-lspconfig setup from mason.lua"
```

---

### Task 4: Verify the configuration

- [ ] **Step 1: Run Neovim headless to check for errors**

Run: `nvim --headless +qa`
Expected: No errors in stderr.

- [ ] **Step 2: Check Mason status**

Run: `nvim --headless +"Mason" +qa` (This might not be easy to verify headless, but checking for runtime errors is a good start)
Actually, checking the file content for consistency is our primary validation here since we are in a CLI environment.
