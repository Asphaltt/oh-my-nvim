local M = {}

function M.copy_yank()
	local lines = vim.fn.getreg('"', 1, true)
	local regtype = vim.fn.getregtype('"')
	local ok, err = pcall(function()
		if (vim.env.SSH_CONNECTION or vim.env.SSH_TTY) and not vim.g.neovide then
			require("vim.ui.clipboard.osc52").copy("+")(lines, regtype)
		else
			vim.fn.setreg("+", lines, regtype)
		end
	end)
	if not ok then
		vim.notify("Copied to unnamed register; clipboard failed: " .. tostring(err), vim.log.levels.WARN)
	end
end

return M
