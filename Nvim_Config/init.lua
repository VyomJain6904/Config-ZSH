-- ========================
-- Bootstrap Lazy.nvim
-- ========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- ========================
-- Lazy.nvim Setup
-- ========================
local opts = {}
require("vim-options")
require("lazy").setup("plugins")
require("config.keymap")

-- ========================
-- Transparency Settings
-- ========================
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        -- General Editor
        vim.cmd [[
            hi Normal guibg=none ctermbg=none
            hi NormalNC guibg=none ctermbg=none
            hi NormalFloat guibg=none ctermbg=none
            hi FloatBorder guibg=none ctermbg=none
            hi SignColumn guibg=none ctermbg=none
            hi LineNr guibg=none ctermbg=none
            hi EndOfBuffer guibg=none ctermbg=none

            " NeoTree
            hi NeoTreeNormal guibg=none ctermbg=none
            hi NeoTreeNormalNC guibg=none ctermbg=none
            hi NeoTreeEndOfBuffer guibg=none ctermbg=none
            hi NeoTreeWinSeparator guibg=none ctermbg=none

            " Telescope
            hi TelescopeNormal guibg=none ctermbg=none
            hi TelescopeBorder guibg=none ctermbg=none
            hi TelescopePromptNormal guibg=none ctermbg=none
            hi TelescopePromptBorder guibg=none ctermbg=none
            hi TelescopeResultsNormal guibg=none ctermbg=none
            hi TelescopeResultsBorder guibg=none ctermbg=none
            hi TelescopePreviewNormal guibg=none ctermbg=none
            hi TelescopePreviewBorder guibg=none ctermbg=none

            " Mason + LSP Float Windows
            hi MasonNormal guibg=none ctermbg=none
            hi Pmenu guibg=none ctermbg=none
            hi LspInfoBorder guibg=none ctermbg=none
            hi DiagnosticFloatBg guibg=none ctermbg=none
        ]]
    end,
})

