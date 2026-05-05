# Consolidate Mason LSP Configuration Implementation Plan v2

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Consolidate `mason-lspconfig` configuration into `lspconfig.lua` and remove redundancy from `mason.lua`.

**Architecture:** Merge all LSP server names into the `ensure_installed` list in `lua/jyrwa/plugins/lsp/lspconfig.lua`, ensure they are initialized in the `servers` table, and remove the `mason_lspconfig` setup from `lua/jyrwa/plugins/lsp/mason.lua`.

**Tech Stack:** Neovim, Lua, Mason, nvim-lspconfig

---

### Task 1: Consolidate `lspconfig.lua`

**Files:**
- Modify: `lua/jyrwa/plugins/lsp/lspconfig.lua`

- [ ] **Step 1: Update `ensure_installed` list**
Add `"html"` to the list. `"dartls"` is already there.

```lua
<<<<
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
====
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
        "dartls",
      },
      automatic_installation = true,
    })
>>>>
```

- [ ] **Step 2: Add `html` to `servers` table**
Ensure the `html` server is initialized.

```lua
<<<<
      eslint = {
        settings = {
          codeAction = { disableRuleComment = { enable = true, location = "separateLine" } },
          useFlatConfig = true,
        },
      },
      sqlls = {},
    }
====
      eslint = {
        settings = {
          codeAction = { disableRuleComment = { enable = true, location = "separateLine" } },
          useFlatConfig = true,
        },
      },
      sqlls = {},
      html = {},
    }
>>>>
```

---

### Task 2: Cleanup `mason.lua`

**Files:**
- Modify: `lua/jyrwa/plugins/lsp/mason.lua`

- [ ] **Step 1: Remove redundant `mason_lspconfig` setup and require**
Remove the unused `require` and the `setup` block.

```lua
<<<<
    -- import mason
    local mason = require("mason")
    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")
====
    -- import mason
    local mason = require("mason")
    local mason_tool_installer = require("mason-tool-installer")
>>>>
```

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

---

### Task 3: Verification and Commit

- [ ] **Step 1: Verify configuration with Neovim headless**
Run: `nvim --headless +qa`
Expected: No errors in stderr.

- [ ] **Step 2: Commit the fix**
Run: `git add lua/jyrwa/plugins/lsp/lspconfig.lua lua/jyrwa/plugins/lsp/mason.lua`
Run: `git commit -m "fix(lsp): consolidate mason-lspconfig ensure_installed list"`
