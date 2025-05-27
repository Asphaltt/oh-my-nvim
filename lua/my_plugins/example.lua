return {
	-- Your Plugin1
	--  {
	--      'hardhacker/plugin1',
	--      config = function() ... end
	--  },

	-- Your Plugin2
	--  {'hardhacker/plugin2'},
	--
	--[[ {
		"zbirenbaum/copilot-cmp",
		event = "InsertEnter",
		config = function()
			require("copilot_cmp").setup()
		end,
		dependencies = {
			"zbirenbaum/copilot.lua",
			cmd = "Copilot",
			config = function()
				require("copilot").setup({
					suggestion = { enabled = false },
					panel = { enabled = false },
				})
			end,
		},
	},
	]]
}
