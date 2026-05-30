# Spec: nvim-spectre Integration

**Date:** 2026-05-30
**Status:** APPROVED
**Topic:** Adding nvim-spectre for global search and replace with non-conflicting keymaps.

## 1. Purpose
Enhance the Neovim configuration with robust global search and replace capabilities using `nvim-spectre`.

## 2. Architecture
- **Plugin Management:** Use `lazy.nvim` to manage `nvim-spectre`.
- **Modular Config:** Define the plugin in its own file: `lua/jyrwa/plugins/spectre.lua`.
- **Global Keymaps:** Add Spectre keymaps to `lua/jyrwa/core/keymaps.lua` to maintain a centralized keybinding registry.

## 3. Implementation Details

### 3.1 Plugin Definition (`lua/jyrwa/plugins/spectre.lua`)
```lua
return {
  "nvim-pack/nvim-spectre",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("spectre").setup()
  end,
}
```

### 3.2 Keymap Definitions (`lua/jyrwa/core/keymaps.lua`)
We will use the `<leader>S` prefix to avoid conflicts with `<leader>s` (window splits/search history) and `<leader>f` (Telescope).

| Keymap | Action | Description |
|--------|--------|-------------|
| `<leader>Sr` | `require("spectre").toggle()` | Toggle Spectre Search & Replace |
| `<leader>Sw` | `require("spectre").open_visual({select_word=true})` | Search current word in Spectre |
| `<leader>Sf` | `require("spectre").open_file_search()` | Search in current file |

## 4. Success Criteria
- [ ] `nvim-spectre` is installed and loads without errors.
- [ ] `<leader>Sr` opens the Spectre UI.
- [ ] `<leader>Sw` populates Spectre with the word under the cursor.
- [ ] No existing keymaps are overwritten or broken.
