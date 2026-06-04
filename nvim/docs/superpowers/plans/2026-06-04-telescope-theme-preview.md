# Telescope Theme Preview & Tokyo Night Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a live theme preview using Telescope with `<leader>fh` and integrate the Tokyo Night colorscheme.

**Architecture:** Centralize all colorschemes in the existing `colorscheme.lua` plugin file and add a dedicated Telescope mapping for theme switching.

**Tech Stack:** Neovim, lazy.nvim, Telescope, Catppuccin, Tokyo Night.

---

### Task 1: Add Tokyo Night to Colorscheme Configuration

**Files:**
- Modify: `lua/jyrwa/plugins/colorscheme.lua`

- [ ] **Step 1: Update colorscheme plugin list**

Modify the file to return a list containing both catppuccin and tokyonight.

```lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        -- ... (keep existing config)
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
}
```

- [ ] **Step 2: Commit changes**

```bash
git add lua/jyrwa/plugins/colorscheme.lua
git commit -m "feat: add tokyonight colorscheme"
```

### Task 2: Add Telescope Theme Preview Keymap

**Files:**
- Modify: `lua/jyrwa/core/keymaps.lua`

- [ ] **Step 1: Add `<leader>fh` mapping**

Add the mapping in the Telescope section.

```lua
-- lua/jyrwa/core/keymaps.lua around line 60

keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
keymap.set("n", "<leader>fh", "<cmd>Telescope colorscheme enable_preview=true<cr>", { desc = "Fuzzy find themes" })
keymap.set("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
```

- [ ] **Step 2: Commit changes**

```bash
git add lua/jyrwa/core/keymaps.lua
git commit -m "feat: add telescope theme preview keymap"
```

### Task 3: Verification

- [ ] **Step 1: Open Neovim and run `:Lazy`**
Verify that both `catppuccin` and `tokyonight` are loaded/installed.

- [ ] **Step 2: Trigger Telescope theme preview**
Press `<leader>fh` and scroll through the list. Verify that the theme changes as you scroll.

- [ ] **Step 3: Select Tokyo Night**
Press `<CR>` on a Tokyo Night variant and verify it applies.
