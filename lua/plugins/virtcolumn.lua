return {
	"lukas-reineke/virt-column.nvim",
	config = function()
		require("virt-column").setup({
			virtcolumn = "75,80,100,120",
		})
	end,
}
