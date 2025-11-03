return {
	-- Mason
	{
		"williamboman/mason.nvim",
        opts = {
            ui = {
                icons = {
                    package_installed = "✔",
                    package_pending = "➤",
                    package_uninstalled = "X",
                },
            },
        },
	},

	-- Mason-LSPConfig bridge
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "rust_analyzer", "lua_ls", "ts_ls" },
                automatic_installation = true,
			})
		end,
	},

	-- LSP config
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

			lspconfig.rust_analyzer.setup({})
			lspconfig.lua_ls.setup({})
			lspconfig.ts_ls.setup({})

			-- Keymaps for LSP
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
