# Design Doc - Define Keymaps for nvim-spectre

**Version:** 1.0.0 | **Status:** APPROVED
**Created:** 2026-05-30 | **Last Updated:** 2026-05-30

## Purpose

Add global keybindings for `nvim-spectre` to `lua/jyrwa/core/keymaps.lua` to provide easy access to search and replace functionality.

## Approach

1.  **Context:** The current `keymaps.lua` file is organized into sections by plugin.
2.  **Implementation:** Append a new section for `Spectre (Search & Replace)` at the end of the file.
3.  **Keymaps:**
    *   `<leader>Sr`: Toggle Spectre UI.
    *   `<leader>Sw`: Search for the word under the cursor.
    *   `<leader>Sf`: Search within the current file.

## Keymaps Definition

```lua
-- Spectre (Search & Replace)
keymap.set("n", "<leader>Sr", '<cmd>lua require("spectre").toggle()<CR>', {
  desc = "Toggle Spectre",
})
keymap.set("n", "<leader>Sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
  desc = "Search current word",
})
keymap.set("n", "<leader>Sf", '<cmd>lua require("spectre").open_file_search()<CR>', {
  desc = "Search on current file",
})
```

## Verification Plan

1.  Read the file `lua/jyrwa/core/keymaps.lua` after the update to ensure the lines are present and correctly formatted.
2.  Check for any syntax errors in the modified file.

## Success Metrics

*   `lua/jyrwa/core/keymaps.lua` contains the new Spectre keymaps.
*   The change is committed with the message: "feat(keymaps): add Spectre search and replace shortcuts".
