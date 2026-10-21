return {
	{
		"nvim-telescope/telescope.nvim",
		opts = {
			defaults = {
				sorting_strategy = "descending",
			},
			pickers = {
				-- Keep grep matches at the top instead of below padded blank rows.
				grep_string = { sorting_strategy = "descending" },
				live_grep = { sorting_strategy = "descending" },
				buffers = { sort_mru = true },
			},
		},
		dependencies = {
			{ "nvim-lua/popup.nvim" },
			{ "nvim-lua/plenary.nvim" },

			{ "nvim-telescope/telescope-fzy-native.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons",             enabled = vim.g.have_nerd_font },
		},
		keys = {
			{
				require("custom_keys").find_files,
				require("telescope.builtin").find_files,
				desc = "Telescope Find Files",
			},
			{
				require("custom_keys").live_grep,
				require("telescope.builtin").live_grep,
				desc = "Telescope Live Grep",
			},
			{
				require("custom_keys").search_cursor,
				require("telescope.builtin").grep_string,
				desc = "Telescope Grep String",
			},
			{
				require("custom_keys").find_buffer,
				require("telescope.builtin").buffers,
				desc = "Telescope Find Buffers",
			},
		},
	},
}
