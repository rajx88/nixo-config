local set = vim.keymap.set

-- file explorer
set("n", "<leader>pv", vim.cmd.Ex)

-- Visual mode Move selected text up and down
set("v", "J", ":m '>+1<CR>gv=gv")
set("v", "K", ":m '<-2<CR>gv=gv")

-- Joins lines without moving the cursor
set("n", "J", "mzJ`z")

-- Scroll up and down and center the cursor
set("n", "<C-d>", "<C-d>zz")
set("n", "<C-u>", "<C-u>zz")

-- Keep cursor centered when cycling through the search results
set("n", "n", "nzzzv")
set("n", "N", "Nzzzv")

-- clipboard pasting
set("x", "<leader>p", [["_dP]])

-- yank to system clipboard
set({ "n", "v" }, "<leader>y", [["+y]])
set("n", "<leader>Y", [["+Y]])

-- delete to the blackhole register
set({ "n", "v" }, "<leader>d", '"_d')

-- Basic movement keybinds, these make navigating splits easy for me
set("n", "<c-j>", "<c-w><c-j>")
set("n", "<c-k>", "<c-w><c-k>")
set("n", "<c-l>", "<c-w><c-l>")
set("n", "<c-h>", "<c-w><c-h>")

set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
set("n", "<leader>\\", "<C-W>v", { desc = "Split Window Right", remap = true })

set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- save file
set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- quit
set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
