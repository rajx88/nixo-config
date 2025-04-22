local opt = vim.opt

-- set termguicolors to enable highlight groups
opt.termguicolors = true

-- disable background
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

opt.inccommand = "split"
opt.splitbelow = true
opt.splitright = true

-- See `:help vim.o`
-- Set highlight on search
opt.hlsearch = false

-- Make line numbers default
opt.number = true
opt.relativenumber = true

vim.opt.cursorline = true

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = "unnamedplus"

-- Enable break indent
opt.breakindent = true

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv "HOME" .. "/.config/nvim/undodir"
opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
opt.ignorecase = true
opt.smartcase = true

opt.scrolloff = 10
opt.signcolumn = "yes"

-- Decrease update time
opt.updatetime = 50

vim.opt.confirm = true
