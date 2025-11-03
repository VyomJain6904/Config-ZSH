return { -- Neo-tree
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
        require("neo-tree").setup({
            window = {
                position = "right", -- Shift tree to the right side
            },
        })

        -- ===================
        -- Neo-tree Keymap
        -- ===================
        vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", { noremap = true, silent = true })
    end
}

