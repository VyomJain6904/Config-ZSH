return {
	-- Dracula theme
	"Mofiqul/dracula.nvim",
	name = "dracula",
	priority = 1000,
	config = function()
		require("dracula").setup({
			flavour = "mocha",
            transparent_background = true,
			integrations = {
				telescope = true,
				treesitter = true,
				which_key = true,
				neotree = true,
                gitsigns = true,
            },
		})
		vim.cmd.colorscheme("dracula")
	end,
}
