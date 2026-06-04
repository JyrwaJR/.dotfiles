# Multi-Theme Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add One Dark Pro, Poimandres, Bluloco, Night Owl, Cobalt2, and Solarized Osaka colorschemes to the Neovim configuration.

**Architecture:** Add all theme plugins to the existing `lua/jyrwa/plugins/colorscheme.lua` list. Themes with dependencies (Bluloco, Cobalt2) will have them defined inline.

**Tech Stack:** Neovim, lazy.nvim, Telescope.

---

### Task 1: Add New Themes to Colorscheme Configuration

**Files:**
- Modify: `lua/jyrwa/plugins/colorscheme.lua`

- [ ] **Step 1: Add theme plugins to the return list**

Modify `lua/jyrwa/plugins/colorscheme.lua` to include the new themes.

```lua
return {
  -- ... (catppuccin and tokyonight remain at the top)
  
  -- One Dark Pro
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
  },

  -- Poimandres
  {
    "olivercederborg/poimandres.nvim",
    priority = 1000,
    opts = {
      -- Add any specific opts here if needed
    },
  },

  -- Bluloco
  {
    "uloco/bluloco.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "rktjmp/lush.nvim" },
    config = function()
      require("bluloco").setup({
        transparent = true,
        italics = true,
      })
    end,
  },

  -- Night Owl
  {
    "oxfist/night-owl.nvim",
    priority = 1000,
  },

  -- Cobalt2
  {
    "lalitmee/cobalt2.nvim",
    priority = 1000,
    dependencies = { "tjdevries/colorbuddy.nvim" },
  },

  -- Solarized Osaka (Solaris)
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
    },
  },
}
```

- [ ] **Step 2: Commit changes**

```bash
git add lua/jyrwa/plugins/colorscheme.lua
git commit -m "feat: add multiple themes (onedark, poimandres, bluloco, night-owl, cobalt2, solarized-osaka)"
```

### Task 2: Verification

- [ ] **Step 1: Open Neovim and run `:Lazy`**
Verify that all new themes are listed and either installed or downloading.

- [ ] **Step 2: Test Telescope Theme Picker**
Press `<leader>fh`. Verify that all new themes (onedark, poimandres, bluloco, night-owl, cobalt2, solarized-osaka) appear in the list.

- [ ] **Step 3: Test Live Preview**
Scroll through the themes and ensure the UI updates correctly for each one.
