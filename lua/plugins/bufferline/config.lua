return function()
	local bufferline = require("bufferline")
	bufferline.setup({
		options = {
			mode = "buffers",                      -- set to "tabs" to only show tabpages instead
			style_preset = bufferline.style_preset.default, -- or bufferline.style_preset.minimal,
			themable = true,                       -- allows highlight groups to be overriden i.e. sets highlights as default
			highlights = {
				buffer_selected = {
					bg = "#969696",
					bold = true,
				},
			},
			--numbers = function(opts)
			--	return string.format("%s·%s", opts.raise(opts.id), opts.lower(opts.ordinal))
			--end,
			indicator = {
				-- icon = "* ", -- this should be omitted if indicator style is not 'icon'
				style = "icon",
			},
			diagnostics = "nvim_lsp",
			diagnostics_update_in_insert = false,
			diagnostics_indicator = function(count, level, diagnostics_dict, context)
				local s = " "
				for e, n in pairs(diagnostics_dict) do
					local sym = e == "error" and "❌ " or (e == "warning" and "❕" or "❔")
					s = s .. n .. sym
				end
				return s
			end,
			offsets = {
				{
					filetype = "neo-tree",
					text = require("custom_opts").file_explorer_title,
					text_align = "left",
					separator = true,
				},
			},
			color_icons = false, -- whether or not to add the filetype icon highlights
			--separator_style = require("custom_opts").tab_style,
			separator_style = "thin",
			hover = {
				enabled = true,
				delay = 200,
				reveal = { "close" },
			},
		},
	})
end
