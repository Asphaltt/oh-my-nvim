return {
	"lukas-reineke/virt-column.nvim",
	config = function()
		require("virt-column").setup({
			virtcolumn = vim.g.colorcolumn,
		})
	end,
}
