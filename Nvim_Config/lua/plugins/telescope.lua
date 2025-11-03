return {
	{
		-- Telescope
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			-- ===================
			-- Telescope Keymaps
			-- ===================
			local builtin = require "telescope.builtin"
			vim.keymap.set("n", "<C-f>", builtin.find_files, { desc = "Telescope Find Files" })
			vim.keymap.set("n", "<C-g>", builtin.live_grep, { desc = "Telescope Live Grep" })
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
