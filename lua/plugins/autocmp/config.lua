return function()
	local cmp = require("cmp")

	cmp.setup({
		visible = true,
		preselect = "item",
		completion = {
			autocomplete = {
				cmp.TriggerEvent.TextChanged,
				cmp.TriggerEvent.InsertEnter,
			},
			completeopt = "menu,menuone,noinsert",
			keyword_length = 0,
		},
		snippet = {
			-- Select the luasnip engine here. You can switch to another engine.
			expand = function(args)
				-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
				require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
				-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
				-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
			end,
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		formatting = {
			format = require("lspkind").cmp_format({
				mode = "symbol_text",
				maxwidth = 50,
				ellipsis_char = "...",
			}),
		},
		mapping = cmp.mapping.preset.insert({
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

			-- https://lsp-zero.netlify.app/docs/autocomplete.html#enable-super-tab
			-- Super tab
			["<Tab>"] = cmp.mapping(function(fallback)
				local luasnip = require("luasnip")
				local col = vim.fn.col(".") - 1

				if cmp.visible() then
					cmp.select_next_item({ behavior = "select" })
				elseif luasnip.expand_or_locally_jumpable() then
					luasnip.expand_or_jump()
				elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
					fallback()
				else
					cmp.complete()
				end
			end, { "i", "s" }),

			-- Super shift tab
			["<S-Tab>"] = cmp.mapping(function(fallback)
				local luasnip = require("luasnip")

				if cmp.visible() then
					cmp.select_prev_item({ behavior = "select" })
				elseif luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
		}),
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "git" },
			{ name = "luasnip" },
			{
				name = "go_deep",
				keyword_length = 3,
				max_item_count = 5,
				---@module "cmp_go_deep"
				---@type cmp_go_deep.Options
				option = {
					-- See below for configuration options
				},
			},
		}, {
			{ name = "buffer" },
			{ name = "path" },
		}),
	})

	-- `/` cmdline setup.
	cmp.setup.cmdline("/", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer" },
		},
	})

	-- `:` cmdline setup.
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{
				name = "cmdline",
				option = {
					ignore_cmds = { "Man", "!" },
				},
			},
		}),
	})

	-- If you want insert `(` after select function or method item
	local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end
