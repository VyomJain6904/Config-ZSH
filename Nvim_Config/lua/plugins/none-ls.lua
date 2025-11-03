return {
    "nvimtools/none-ls.nvim",
    dependencies = { "williamboman/mason.nvim", "jay-babu/mason-null-ls.nvim" },
    config = function()
        local null_ls = require("null-ls")

        -- Setup sources
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.formatting.prettier,
            },
        })

        -- Format on <leader>f
        vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
        end, { desc = "Format code" })
    end,
}
