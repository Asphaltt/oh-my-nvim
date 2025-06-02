return {
	{
		"nvim-telescope/telescope.nvim",
		defaults = {
			-- Sort by most recently used first
			sorting_strategy = "descending",
			sort_mru = true,
		},
		dependencies = {
			{ "nvim-lua/popup.nvim" },
			{ "nvim-lua/plenary.nvim" },

			{ "nvim-telescope/telescope-fzy-native.nvim" },
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({})

			local option = { noremap = true, silent = true }

			local keys = require("custom_keys")
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", keys.find_files, builtin.find_files, option)
			vim.keymap.set("n", keys.live_grep, builtin.live_grep, option)
			vim.keymap.set("n", keys.search_cursor, builtin.grep_string, option)
			vim.keymap.set("n", keys.find_buffer, builtin.buffers, option)
		end,
	},
}
