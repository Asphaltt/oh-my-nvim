return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v4.x",
		lazy = true,
		config = false,
	},

	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
					border = "rounded",
				},
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		cmd = { "LspInfo", "LspInstall", "LspStart" },
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
		},
		config = function()
			require("plugins/lspconfig/config")()

			local lsp_zero = require("lsp-zero")

			lsp_zero.extend_lspconfig({
				sign_text = true,
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			local lspconfig = require("lspconfig")
			lspconfig.gopls.setup({
				cmd = { "gopls" },
				cmd_env = {
					GOOS = "linux",
				},
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
							shadow = true,
						},
						staticcheck = true,
						gofumpt = true,
					},
				},
			})
		end,
	},

	{
		"mason-org/mason-lspconfig.nvim",
		opts = {},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", "gopls" },
				automatic_enable = false,
				automatic_installation = true,
			})

			local lspconfig = require("lspconfig")
			-- local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- lspconfig.gopls.setup({
			--     capabilities = capabilities,
			-- })

			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						diagnostics = {
							enable = true,
							globals = { "vim" }, -- prevent 'undefined global vim' warning
						},
						workspace = {
							checkThirdParty = false,
							library = vim.api.nvim_get_runtime_file("", true),
						},
						telemetry = { enable = false },
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			})
		end,
	},

	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local null_ls = require("null-ls")
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

			null_ls.setup({
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
				root_dir = require("null-ls.utils").root_pattern(".null-ls-root", "Makefile", ".git"),
				should_attach = nil,
				sources = nil,
				temp_dir = nil,
				update_in_insert = false,
			}) -- end of setup
		end,
	},

	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				automatic_setup = true,
				ensure_installed = { "shfmt", "prettier", "stylua" },
				handlers = {},
			})
		end,
	},

	{
		"p00f/clangd_extensions.nvim",
		config = function()
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
					--[[ These are unicode, should be available in any font
					role_icons = {
						type = "🄣",
						declaration = "🄓",
						expression = "🄔",
						statement = ";",
						specifier = "🄢",
						["template argument"] = "🆃",
					},
					kind_icons = {
						Compound = "🄲",
						Recovery = "🅁",
						TranslationUnit = "🅄",
						PackExpansion = "🄿",
						TemplateTypeParm = "🅃",
						TemplateTemplateParm = "🅃",
						TemplateParamObject = "🅃",
					},]]
					-- These require codicons (https://github.com/microsoft/vscode-codicons)
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

			-- require("clangd_extensions.inlay_hints").setup_autocmd()
			-- require("clangd_extensions.inlay_hints").set_inlay_hints()
		end,
	},
}
