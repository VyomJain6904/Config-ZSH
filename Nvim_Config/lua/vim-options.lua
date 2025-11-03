-- ============================
-- Basic Tab & Indent Settings
-- ============================
vim.cmd("set expandtab") -- Use spaces instead of tabs
vim.cmd("set tabstop=4") -- Number of spaces tabs count for
vim.cmd("set softtabstop=4") -- Number of spaces for editing operations
vim.cmd("set shiftwidth=4") -- Number of spaces for indentation
vim.g.mapleader = " "
vim.opt.number = true -- Show line Numbers

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Text Wrapping
vim.opt.wrap = true
vim.opt.breakindent = true

-- Window Spliting
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.winborder = "rounded"
