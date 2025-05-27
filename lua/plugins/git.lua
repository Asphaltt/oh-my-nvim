return {
	{
		"lewis6991/gitsigns.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitsigns").setup({
				current_line_blame = false,
				preview_config = {
					border = "rounded",
				},
			})
		end,
	},

	{ "sindrets/diffview.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

	{
		"APZelos/blamer.nvim",
		config = function ()
			vim.g.blamer_enabled = true
			vim.g.blamer_delay = 100
		end
	},
}
