return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v4.x",
		lazy = true,
		config = false,
	},

	{
		"mason-org/mason.nvim",
		lazy = false,
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
				border = "rounded",
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile", "InsertEnter" },
		dependencies = {
			{ "mason-org/mason.nvim" },
			{ "hrsh7th/cmp-nvim-lsp" },

			-- Additional lua configuration, makes nvim stuff amazing!
			"folke/neodev.nvim",
			"ray-x/lsp_signature.nvim",
		},
		config = function()
			require("plugins/lspconfig/config")()
		end,
	},

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = { "lua_ls", "clangd", "gopls" },
			automatic_enable = false,
		},
	},

	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			border = "rounded",
			cmd = { "nvim" },
			debounce = 250,
			debug = false,
			default_timeout = 5000,
			diagnostic_config = {},
			diagnostics_format = "#{m}",
			fallback_severity = vim.diagnostic.severity.ERROR,
			log_level = "warn",
			notify_format = "[null-ls] %s",
			on_init = nil,
			on_exit = nil,
			-- root_dir = require("null-ls.utils").root_pattern(".null-ls-root", "Makefile", ".git"),
			should_attach = nil,
			sources = nil,
			temp_dir = nil,
			update_in_insert = false,
		},
	},

	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		opts = {
			automatic_setup = true,
			ensure_installed = { "shfmt", "prettier", "stylua" },
		},
	},

	{
		"p00f/clangd_extensions.nvim",
		config = function()
			require("lspconfig").clangd.setup({})

			require("clangd_extensions").setup({
				inlay_hints = {
					inline = vim.fn.has("nvim-0.10") == 1,
					-- Options other than `highlight' and `priority' only work
					-- if `inline' is disabled
					-- Only show inlay hints for the current line
					only_current_line = false,
					-- Event which triggers a refresh of the inlay hints.
					-- You can make this { "CursorMoved" } or { "CursorMoved,CursorMovedI" } but
					-- note that this may cause higher CPU usage.
					-- This option is only respected when only_current_line is true.
					only_current_line_autocmd = { "CursorHold" },
					-- whether to show parameter hints with the inlay hints or not
					show_parameter_hints = true,
					-- prefix for parameter hints
					parameter_hints_prefix = "<- ",
					-- prefix for all the other hints (type, chaining)
					other_hints_prefix = "=> ",
					-- whether to align to the length of the longest line in the file
					max_len_align = false,
					-- padding from the left if max_len_align is true
					max_len_align_padding = 1,
					-- whether to align to the extreme right or not
					right_align = false,
					-- padding from the right if right_align is true
					right_align_padding = 7,
					-- The color of the hints
					highlight = "Comment",
					-- The highlight group priority for extmark
					priority = 100,
				},
				ast = {
					role_icons = {
						type = "",
						declaration = "",
						expression = "",
						specifier = "",
						statement = "",
						["template argument"] = "",
					},

					kind_icons = {
						Compound = "",
						Recovery = "",
						TranslationUnit = "",
						PackExpansion = "",
						TemplateTypeParm = "",
						TemplateTemplateParm = "",
						TemplateParamObject = "",
					},

					highlights = {
						detail = "Comment",
					},
				},
				memory_usage = {
					border = "none",
				},
				symbol_info = {
					border = "none",
				},
			})
		end,
	},
}
