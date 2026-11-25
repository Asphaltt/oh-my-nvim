local M = {}

function M.copy()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1
	local offset, url = 1, nil
	while true do
		local first, last = line:find("[%a][%w+%.%-]*://[^%s<>\"'`]+", offset)
		if not first then
			break
		end
		local candidate = line:sub(first, last)
		-- Trim prose punctuation and unmatched Markdown/bracket delimiters.
		while true do
			local tail = candidate:sub(-1)
			local opener = ({ [")"] = "(", ["]"] = "[", ["}"] = "{" })[tail]
			local trim = tail:match("[.,;:!?]") ~= nil
			if opener then
				local _, opens = candidate:gsub("%" .. opener, "")
				local _, closes = candidate:gsub("%" .. tail, "")
				trim = closes > opens
			end
			if not trim then
				break
			end
			candidate = candidate:sub(1, -2)
		end
		if col >= first and col < first + #candidate then
			url = candidate
			break
		end
		offset = last + 1
	end
	if not url then
		vim.notify("No URL under the cursor", vim.log.levels.WARN)
		return
	end

	vim.fn.setreg('"', url)
	local remote = (vim.env.SSH_CONNECTION or vim.env.SSH_TTY) and not vim.g.neovide
	local ok, err = pcall(function()
		if remote then
			require("vim.ui.clipboard.osc52").copy("+")({ url }, "v")
		else
			vim.fn.setreg("+", url)
		end
	end)
	if not ok then
		vim.notify("Copied to unnamed register; clipboard failed: " .. tostring(err), vim.log.levels.WARN)
	else
		vim.notify((remote and "Sent to terminal clipboard: " or "Copied: ") .. url)
	end
end

return M
