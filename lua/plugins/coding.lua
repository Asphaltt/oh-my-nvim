return {
	-- auto-tag
	{
		"windwp/nvim-ts-autotag",
		opts = {},
	},

	-- auto-pairs
	{
		"windwp/nvim-autopairs",
		opts = {
			enable_check_bracket_line = false,
			ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
		},
	},

	-- auto completion
	{
		"hrsh7th/nvim-cmp",
		version = false,
		event = "InsertEnter",
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-cmdline" },
			{ "hrsh7th/cmp-emoji" },
			{ "petertriho/cmp-git" },
			{ "L3MON4D3/LuaSnip" }, -- install the LuaSnip engine
			{ "onsails/lspkind.nvim" }, -- icons in autocomplete source
			{ "samiulsami/cmp-go-deep", dependencies = { "kkharji/sqlite.lua" } },
		},
		config = function()
			require("cmp_git").setup()
			require("plugins/autocmp/config")()
		end,
	},

	{
		"delphinus/cmp-ctags",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			require("cmp").setup({
				sources = {
					{
						name = "ctags",
						-- default values
						option = {
							executable = "ctags",
							trigger_characters = { "." },
							trigger_characters_ft = {},
						},
					},
				},
			})
		end,
	},

	-- todo comments
	-- Preview
	-- TODO: todo
	-- FIX: fix
	-- WARNING: warning
	-- HACK: hack
	-- NOTE: note
	-- PERF: perf
	-- TEST: test
	--
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			keywords = {
				FIX = {
					icon = " ", -- icon used for the sign, and in search results
					color = "error", -- can be a hex color, or a named color (see below)
					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
					-- signs = false, -- configure signs for some keywords individually
				},
				TODO = { icon = " ", color = "todo" },
				HACK = { icon = " ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = "󱢍", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = " ", color = "info", alt = { "INFO" } },
				TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				todo = { "DiagnosticOk", "#2563EB" },
				info = { "DiagnosticInfo", "#10B981" },
				default = { "Identifier", "#7C3AED" },
				test = { "Identifier", "#FF00FF" },
			},
		},
	},

	-- guess indent
	{
		"nmac427/guess-indent.nvim",
		opts = {},
	},
}
