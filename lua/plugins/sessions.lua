return {
	"rmagatti/auto-session",
	lazy = true,
	dependencies = {
		"nvim-telescope/telescope.nvim", -- Only needed if you want to use sesssion lens
	},
	opts = {
		auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
		lazy_support = true,
		-- log_level = 'debug',
	},
	keys = {
		{ "n", "<leader>ss", ":Telescope sessions<CR>" },
		{ "n", "<leader>sd", ":DeleteSession<CR>" },
		{ "n", "<leader>sl", ":LoadSession<CR>" },
	},
	config = function()
		require("auto-session").setup({
			auto_session_enabled = true,
			auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
			auto_save_enabled = true,
			auto_restore_enabled = true,
			auto_session_suppress_dirs = nil,
			auto_session_allowed_dirs = nil,
			auto_session_create_enabled = true,
			auto_session_enable_last_session = false,
			auto_session_use_git_branch = false,
			auto_restore_lazy_delay_enabled = true,
			log_level = "error",

			session_lens = {
				-- If load_on_setup is false, make sure you use `:SessionSearch` to open the picker as it will initialize everything first
				load_on_setup = true,
				theme_conf = { border = true },
				previewer = false,
				mappings = {
					-- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
					delete_session = { "i", "<C-D>" },
					alternate_session = { "i", "<C-S>" },
				},
			},
		})
	end,
}
