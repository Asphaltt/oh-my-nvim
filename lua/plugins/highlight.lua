return {
	-- Syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup()
			require("nvim-treesitter").install({ "markdown", "markdown_inline", "regex" })

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter_highlight", { clear = true }),
				callback = function()
					if vim.b.large_file then
						return
					end

					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
					if ok and stats and stats.size > max_filesize then
						return
					end

					pcall(vim.treesitter.start)
				end,
			})

			-- let it to use 'markdown' parser for mdx filetype.
			vim.treesitter.language.register("markdown", "mdx")
		end,
	},

	-- Colors highlighting
	{
		"NvChad/nvim-colorizer.lua",
		config = function(plun)
			require("colorizer").setup({
				user_default_options = {
					names = false,
				},
			})
		end,
	},
}
