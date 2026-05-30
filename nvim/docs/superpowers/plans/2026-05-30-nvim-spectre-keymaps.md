# Define Keymaps for nvim-spectre Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add global keybindings for `nvim-spectre` to `lua/jyrwa/core/keymaps.lua`.

**Architecture:** Append keymaps to the end of the existing configuration file.

**Tech Stack:** Neovim (Lua)

---

### Task 1: Append Spectre Keymaps

**Files:**
- Modify: `lua/jyrwa/core/keymaps.lua`

- [ ] **Step 1: Read the current keymaps file**

Check the content of `lua/jyrwa/core/keymaps.lua` to identify the best place to append.

- [ ] **Step 2: Append the Spectre keymaps**

Add the following block to the end of `lua/jyrwa/core/keymaps.lua`:

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

- [ ] **Step 3: Verify the file content**

Read the file again to ensure the keymaps were appended correctly and there are no syntax errors.

- [ ] **Step 4: Commit the change**

```bash
git add lua/jyrwa/core/keymaps.lua
git commit -m "feat(keymaps): add Spectre search and replace shortcuts"
```
