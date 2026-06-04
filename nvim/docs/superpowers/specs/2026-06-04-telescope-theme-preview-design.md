# Telescope Theme Preview & Tokyo Night Integration Design

**Status:** APPROVED
**Created:** 2026-06-04
**Last Updated:** 2026-06-04

## Purpose
Add a Telescope-based theme picker with live preview and integrate the Tokyo Night colorscheme into the existing Neovim configuration.

## Architecture
- **Plugin Management:** Centralize colorscheme plugins in `lua/jyrwa/plugins/colorscheme.lua`.
- **Keymaps:** Define a consistent Telescope keymap for theme switching.

## Proposed Changes

### 1. Plugin Configuration (`lua/jyrwa/plugins/colorscheme.lua`)
- Convert the single plugin return to a table containing both `catppuccin` and `tokyonight.nvim`.
- Configure `tokyonight` with basic defaults (transparent background support).

### 2. Keymap Integration (`lua/jyrwa/core/keymaps.lua`)
- Add `<leader>fh` mapping to trigger `Telescope colorscheme enable_preview=true`.
- Place this mapping in the "Telescope Keymaps" section for consistency.

## Success Metrics
- `<leader>fh` opens Telescope colorscheme picker.
- Live preview works as the user scrolls through themes.
- Tokyo Night is available in the picker.
- Selecting a theme applies it correctly.

## Out of Scope
- Persisting the theme across Neovim restarts (will default to `catppuccin` as per current `colorscheme.lua` logic).
- Advanced Tokyo Night configurations (e.g., custom highlights).
