vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
keymap.set("n", "dd", '"_dd', { noremap = true, desc = "Delete line" })
keymap.set("n", "p", '"_pp', { noremap = true, desc = "paste line" })
-- write file
keymap.set("n", "<leader>w", ":wa<CR>", { noremap = true, silent = false, desc = "Save file" })
--
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

keymap.set("i", "<C-Space>", "<cmd>lua vim.lsp.buf.completion()<CR>", { desc = "Trigger LSP Completion" })
-- Telescope Keymaps
keymap.set(
  "n",
  "<leader>fw",
  "<cmd>Telescope current_buffer_fuzzy_find<cr>",
  { desc = "Find word in the current file" }
)

keymap.set("n", "<leader>fH", "<cmd>Telescope search_history<cr>", { desc = "Find search history" })
keymap.set("n", "<leader>fhc", "<cmd>Telescope command_history<cr>", { desc = "Find commands history" })
keymap.set("n", "<leader>fa", "<cmd>Telescope autocommands<cr>", { desc = "Find auto commands" })
keymap.set("n", "<leader>fC", "<cmd>Telescope commands<cr>", { desc = "Find commands" })
keymap.set("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "Fuzzy find Mark in cwd" })
keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Fuzzy find keymap in cwd" })
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
keymap.set("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
keymap.set("n", "<leader>fb", "<cmd>Telescope file_browser<cr>", { desc = "File Browser" })
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
keymap.set("n", "<leader>fn", "<cmd>Telescope noice<cr>", { desc = "Fuzzy find noice" })
keymap.set("n", "<leader>fu", "<cmd>Telescope undo<cr>", { desc = "Fuzzy find noice" })
keymap.set("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Fuzzy find noice" })
keymap.set("n", "<leader>fj", "<cmd>Telescope jumplist<cr>", { desc = "Fuzzy find jumplist" })
-- Telescope Git
--
-- Auto Session
keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>", { desc = "Restore session for cwd" }) -- restore last workspace session for current directory
keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" }) -- save workspace session for current working directory
keymap.set("n", "<leader>wa", "<cmd>SessionToggleAutoSave<CR>", { desc = "Toggle Auto Save" }) -- save workspace session for current working directory
-- LazyGit
keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "Fuzzy find git diff" })
keymap.set("n", "<leader>fg", "<cmd>Telescope git_files<cr>", { desc = "Find Git Files" })
keymap.set("n", "<leader>gC", "<cmd>Telescope git_bcommits<cr>", { desc = "Fuzzy find commits for current file" })
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Fuzzy find git branches" })
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Fuzzy find git status" })
keymap.set("n", "<leader>gS", "<cmd>Telescope git_stash<cr>", { desc = "Fuzzy find git stash" })
keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Open lazy git" })
keymap.set("n", "<leader>gl", "<cmd>LazyGitLog<cr>", { desc = "Git Logs" })
keymap.set("n", "<leader>gc", "<cmd>LazyGitCurrentFile<cr>", { desc = "Open git for current file" })
keymap.set("n", "<leader>gf", "<cmd>LazyGitFilterCurrentFile<cr>", { desc = "Filter lazy git for current file" })
keymap.set("n", "<leader>gF", "<cmd>LazyGitFilter<cr>", { desc = "Filter lazy git" })

-- Nvim Tree
keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" }) -- toggle file explorer on current file
keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
keymap.set("n", "<leader>en", "<cmd>NvimTreeFindFile<CR>", { desc = "Find file in file explorer" }) -- find file in file explorer
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

-- Obsidian
keymap.set("n", "<leader>of", "<cmd>Telescope obsidian find_notes<cr>", { desc = "Find Obsidian notes" })
keymap.set("n", "<leader>ol", "<cmd>Telescope obsidian backlinks<cr>", { desc = "View backlinks for current note" })
keymap.set("n", "<leader>os", "<cmd>Telescope obsidian search<cr>", { desc = "Search notes content" })
keymap.set("n", "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", { desc = "Open Obsidian" })
keymap.set("n", "<leader>on", "<cmd>ObsidianNew<cr>", { desc = "Open New Note" })
keymap.set("n", "<leader>osw", "<cmd>ObsidianWorkspace<cr>", { desc = "Open Switch Workspace" })
keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<cr>", { desc = "Open Backlinks from current note" })
keymap.set("n", "<leader>ot", "<cmd>ObsidianTomorrow<cr>", { desc = "Create note for tomorrow  " })
keymap.set("n", "<leader>oy", "<cmd>ObsidianYesterday<cr>", { desc = "Create note for yesterday" })
keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<cr>", { desc = "Obsidian Search" })
