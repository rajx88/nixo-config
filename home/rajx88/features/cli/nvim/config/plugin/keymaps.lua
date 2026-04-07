local set = vim.keymap.set

-- Visual mode: move selected text up and down
set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Join lines without moving the cursor
set("n", "J", "mzJ`z", { desc = "Join lines (cursor stays)" })

-- Scroll up/down and center the cursor
set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Keep cursor centered when cycling through search results
set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
set("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })

-- Clipboard / registers
set("x", "<leader>p", [["_dP]], { desc = "Paste over selection" })
set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
set("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })
set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete to blackhole" })

-- Split navigation
set("n", "<c-j>", "<c-w><c-j>", { desc = "Go to lower split" })
set("n", "<c-k>", "<c-w><c-k>", { desc = "Go to upper split" })
set("n", "<c-l>", "<c-w><c-l>", { desc = "Go to right split" })
set("n", "<c-h>", "<c-w><c-h>", { desc = "Go to left split" })

-- Split creation
set("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
set("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })
set("n", "<leader>\\", "<C-W>v", { desc = "Split window right", remap = true })

-- Misc
set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
