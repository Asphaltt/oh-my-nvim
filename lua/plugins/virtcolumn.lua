return {
	"lukas-reineke/virt-column.nvim",
	config = function()
		require("virt-column").setup({
			virtcolumn = "72,75,80,100",
		})
	end,
}
