return {
	-- Catppuccin theme
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
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
		vim.cmd.colorscheme("catppuccin")
	end,
}
