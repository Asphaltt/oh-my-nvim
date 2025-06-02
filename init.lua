-- Basic settings
require("basic")

-- Load plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
if vim.g.neovide then
	vim.opt.guifont = "Hack Nerd Font"
	vim.g.neovide_theme = "auto"

	vim.g.neovide_input_use_logo = 1
	vim.keymap.set({ "n", "v", "s", "x", "o", "i", "l", "c", "t" }, "<D-v>", function()
		vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
	end, { noremap = true, silent = true })
	-- vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
	-- vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
	-- vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
	-- vim.keymap.set("v", "<D-c>", '"+y') -- Copy
	-- vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
	-- vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
	-- vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
	-- vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode

	vim.opt.termguicolors = true
	vim.g.neovide_input_macos_option_key_is_meta = "only_left"
end

vim.g.mapleader = require("custom_keys").leader
vim.g.maplocalleader = ","
vim.g.colorcolumn = "75,80,100,120"
vim.g.colors_name = "tokyonight"
-- vim.env.GOOS = "linux"
vim.g.background = "light"
vim.g.license_author = "Leon Hwang"
vim.g.license_email = "leon.hwang@linux.dev"
vim.g.number = "relativenumber"

vim.opt.cursorcolumn = true
vim.opt.tags = ".tags"
vim.opt.wrap = true

vim.keymap.set("i", "kj", "<Esc>", {})
vim.keymap.set("n", "<leader>q", ":q<CR>", {})
vim.keymap.set("n", "<leader>w", ":w<CR>", {})
-- vim.keymap.set("n", ",l", ":set list listchars=eol:↓,space:·,tab:⇥¬¬,trail:~<CR>", {})
-- disable searching highlight
vim.keymap.set("n", "<leader>/", "<cmd>nohlsearch<CR>", {})
vim.keymap.set("n", "<leader>rr", "<cmd>Telescope lsp_references<CR>", {})
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", {})
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })
--[[ vim.keymap.set("t", "<leader>wl", "<C-\\><C-n> <C-w>l", {}) ]]
vim.keymap.set("n", "<leader>rw", "gwip<cr>", {}) -- rewrap current comments
vim.keymap.set("n", "<leader>nf", "<cmd>NeoTreeFocus<cr>", {})
vim.keymap.set("n", "<leader>gd", "<cmd>FzfLua tags_grep_cword<cr>", {})

vim.api.nvim_create_user_command("Format", function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			["end"] = { args.line2, end_line:len() },
		}
	end
	require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

require("lazy").setup({
	spec = {
		{ import = "plugins" },
		{ import = "languages" },
		{ import = "my_plugins" },
	},
	ui = {
		border = "rounded",

		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
	change_detection = {
		enabled = true,
		notify = false, -- get a notification when changes are found
	},
})

-- Final settings
require("core")
pcall(require, "custom")

vim.cmd([[
noremap <expr> n (v:searchforward ? 'n' : 'N')
noremap <expr> N (v:searchforward ? 'N' : 'n')
]])
