return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		bufdelete = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true },
		indent = {
			enabled = true,
			filter = function(buf)
				return vim.b[buf].large_file ~= true and vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
			end,
		},
		input = { enabled = true },
		picker = { enabled = true },
		notifier = { enabled = true },
		quickfile = { enabled = false },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = {
			enabled = true,
			filter = function(buf)
				return vim.b[buf].large_file ~= true and vim.g.snacks_words ~= false and vim.b[buf].snacks_words ~= false
			end,
		},
	},
	keys = {
		{
			"<leader>bd",
			function()
				require("snacks").bufdelete()
			end,
			desc = "Delete Buffer",
		},
		{
			"<leader>bO",
			function()
				require("snacks").bufdelete.other()
			end,
			desc = "Delete Other Buffers",
		},
	},
}
