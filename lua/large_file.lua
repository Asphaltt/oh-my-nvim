local M = {}

M.max_size = 512 * 1024
M.max_lines = 10000

local group = vim.api.nvim_create_augroup("large_file", { clear = true })

local function file_size(path)
	if not path or path == "" then
		return 0
	end

	local ok, stat = pcall(vim.loop.fs_stat, path)
	if not ok or not stat then
		return 0
	end

	return stat.size or 0
end

local function mark(buf, reason)
	if vim.b[buf].large_file then
		return
	end

	vim.b[buf].large_file = true
	vim.b[buf].large_file_reason = reason
	vim.b[buf].completion = false
	vim.b[buf].snacks_indent = false
	vim.b[buf].snacks_words = false
	vim.b[buf].minianimate_disable = true
	vim.b[buf].minihipatterns_disable = true
end

local function update_global_plugins(buf)
	if M.is_large(buf) then
		if vim.g.blamer_enabled ~= 0 then
			vim.g.large_file_disabled_blamer = true
		end
		vim.g.blamer_enabled = 0
	elseif vim.g.large_file_disabled_blamer then
		vim.g.blamer_enabled = 1
		vim.g.large_file_disabled_blamer = false
	end
end

local function is_large_path(path)
	return file_size(path) > M.max_size
end

function M.is_large(buf)
	buf = buf or 0
	return vim.b[buf].large_file == true
end

function M.apply(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	update_global_plugins(buf)

	if not M.is_large(buf) then
		return
	end

	if vim.api.nvim_get_current_buf() == buf then
		vim.opt_local.cursorline = false
		vim.opt_local.cursorcolumn = false
		vim.opt_local.foldmethod = "manual"
		vim.opt_local.foldexpr = "0"
		vim.opt_local.list = false
		vim.opt_local.wrap = false
		vim.opt_local.spell = false
		vim.opt_local.conceallevel = 0
		vim.opt_local.statuscolumn = ""
		vim.opt_local.signcolumn = "no"
		vim.opt_local.relativenumber = false
		vim.opt_local.synmaxcol = 160
	end

	pcall(vim.treesitter.stop, buf)

	if vim.diagnostic and vim.diagnostic.disable then
		pcall(vim.diagnostic.disable, buf)
	end

	local ok, local_highlight = pcall(require, "local-highlight")
	if ok and local_highlight.is_attached and local_highlight.is_attached(buf) then
		pcall(local_highlight.detach, buf)
	end
end

vim.api.nvim_create_autocmd("BufReadPre", {
	group = group,
	callback = function(ev)
		local path = vim.api.nvim_buf_get_name(ev.buf)
		if is_large_path(path) then
			mark(ev.buf, ("size>%d"):format(M.max_size))
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "FileType" }, {
	group = group,
	callback = function(ev)
		if vim.api.nvim_buf_line_count(ev.buf) > M.max_lines then
			mark(ev.buf, ("lines>%d"):format(M.max_lines))
		end

		M.apply(ev.buf)
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
	group = group,
	callback = function(ev)
		M.apply(ev.buf)
	end,
})

return M
