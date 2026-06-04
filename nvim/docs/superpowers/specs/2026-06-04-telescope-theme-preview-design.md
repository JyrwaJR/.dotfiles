# Telescope Theme Preview & Multi-Theme Integration Design

**Status:** APPROVED
**Created:** 2026-06-04
**Last Updated:** 2026-06-04

## Purpose
Expand the Neovim colorscheme collection to include a variety of popular themes (One Dark Pro, Poimandres, Bluloco, Night Owl, Cobalt2, and Solarized Osaka) and ensure they are all previewable via Telescope.

## Architecture
- **Plugin Management:** Centralize all colorscheme plugins in `lua/jyrwa/plugins/colorscheme.lua`.
- **Keymaps:** Use the existing `<leader>fh` keymap for Telescope theme switching.

## Proposed Changes

### 1. Plugin Configuration (`lua/jyrwa/plugins/colorscheme.lua`)
Expand the plugin list to include:
- `catppuccin/nvim` (Existing)
- `folke/tokyonight.nvim` (Existing)
- `olimorris/onedarkpro.nvim` (New)
- `olivercederborg/poimandres.nvim` (New)
- `uloco/bluloco.nvim` (New, depends on `rktjmp/lush.nvim`)
- `oxfist/night-owl.nvim` (New)
- `lalitmee/cobalt2.nvim` (New, depends on `tjdevries/colorbuddy.nvim`)
- `craftzdog/solarized-osaka.nvim` (New)

### 2. Dependencies
Ensure themes requiring helper plugins have them correctly specified:
- `Bluloco` -> `lush.nvim`
- `Cobalt2` -> `colorbuddy.nvim`

## Success Metrics
- `<leader>fh` opens Telescope colorscheme picker.
- All new themes appear in the list.
- Live preview works for all new themes.
- Each theme integrates correctly with existing UI elements (Telescope, Bufferline, Lualine, etc.).

## Out of Scope
- Persisting theme selection across sessions (will still default to Catppuccin on startup).
- Deep customization of each individual theme.
