vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab
-- Noice notifications
keymap.set("n", "<leader>cn", "<cmd>NoiceDismiss<CR>", { desc = "Close all notifications" })
-- Telescope Keymaps
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
keymap.set("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
keymap.set("n", "<leader>fn", "<cmd>Telescope noice<cr>", { desc = "Fuzzy find noice" })
keymap.set("n", "<leader>fgC", "<cmd>Telescope git_bcommits<cr>", { desc = "Fuzzy find commits for current file" })
keymap.set("n", "<leader>fgc", "<cmd>Telescope git_commits<cr>", { desc = "Fuzzy find commit" })
keymap.set("n", "<leader>fgs", "<cmd>Telescope git_status<cr>", { desc = "Fuzzy find git status" })
keymap.set("n", "<leader>fgb", "<cmd>Telescope git_branches<cr>", { desc = "Fuzzy find git branches" })
-- Auto Session
keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
keymap.set("n", "<leader>wa", "<cmd>SessionToggleAutoSave<CR>", { desc = "Toggle Auto Save" }) -- save workspace session for current working directory
-- INC Rename
keymap.set("n", "<leader>rn", "<cmd>IncRename<CR>", { desc = "Inc Rename" })

-- LazyGit
keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "Open lazy git" })
-- Nvim Tree
keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" }) -- toggle file explorer on current file
keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
-- Trouble
keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Toggle Trouble" })
keymap.set("n", "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble workspace diagnostics" })
keymap.set(
  "n",
  "<leader>xd",
  "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
  { desc = "Toggle Trouble document diagnostics" }
)
keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", { desc = "Toggle Trouble quickfix list" })
keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Toggle Trouble location list" })
keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Toggle Todos in Trouble" })
-- Vim Maximizer
keymap.set("n", "<leader>sm", "<cmd>MaximizerToggle<cr>", { desc = "Toggle Maximizer" })
