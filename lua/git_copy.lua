local M = {}

function M.copy(kind)
	local path = vim.api.nvim_buf_get_name(0)
	if vim.bo.buftype ~= "" or path == "" then
		vim.notify("Open a tracked file to copy its line's commit", vim.log.levels.WARN)
		return
	end

	local line = vim.api.nvim_win_get_cursor(0)[1]
	local contents = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") .. "\n"
	local output, errors = {}, {}
	local job = vim.fn.jobstart({
		"git", "-C", vim.fn.fnamemodify(path, ":h"),
		"blame", "--line-porcelain", "--contents", "-",
		"-L", line .. "," .. line, "--", path,
	}, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			output = data
		end,
		on_stderr = function(_, data)
			errors = data
		end,
		on_exit = function(_, code)
			vim.schedule(function()
				if code ~= 0 then
					vim.notify("Git blame failed: " .. table.concat(errors, "\n"), vim.log.levels.WARN)
					return
				end
				local sha = (output[1] or ""):match("^(%x+)%s")
				if not sha or sha:match("^0+$") then
					vim.notify("This line has no commit (uncommitted changes)", vim.log.levels.WARN)
					return
				end
				local title
				for _, text in ipairs(output) do
					title = text:match("^summary (.*)$")
					if title then
						break
					end
				end
				local value = kind == "hash" and sha or kind == "title" and (title or "")
					or sha .. " " .. (title or "")
				vim.fn.setreg('"', value)
				local remote = (vim.env.SSH_CONNECTION or vim.env.SSH_TTY) and not vim.g.neovide
				local ok, err
				if remote then
					-- Send the clipboard to the local terminal through SSH (OSC 52).
					ok, err = pcall(function()
						require("vim.ui.clipboard.osc52").copy("+")({ value }, "v")
					end)
				else
					ok, err = pcall(vim.fn.setreg, "+", value)
				end
				if not ok then
					vim.notify("Copied to unnamed register; clipboard failed: " .. tostring(err), vim.log.levels.WARN)
				else
					vim.notify((remote and "Sent to terminal clipboard: " or "Copied: ") .. value)
				end
			end)
		end,
	})
	if job <= 0 then
		vim.notify("Could not start git blame", vim.log.levels.ERROR)
		return
	end
	vim.fn.chansend(job, contents)
	vim.fn.chanclose(job, "stdin")
end

return M
