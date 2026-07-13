return function()
	local colors = {
		red = "#ca1243",
		grey = "#a0a1a7",
		black = "#383a42",
		white = "#f3f3f3",
		light_green = "#83a598",
		orange = "#fe8019",
		green = "#8ec07c",
	}

	local theme = {
		normal = {
			a = { fg = colors.white, bg = colors.black },
			b = { fg = colors.white, bg = colors.grey },
			c = { fg = colors.black, bg = colors.white },
			z = { fg = colors.white, bg = colors.black },
		},
		insert = { a = { fg = colors.black, bg = colors.light_green } },
		visual = { a = { fg = colors.black, bg = colors.orange } },
		replace = { a = { fg = colors.black, bg = colors.green } },
	}

	local empty = require("lualine.component"):extend()
	function empty:draw(default_highlight)
		self.status = ""
		self.applied_separator = ""
		self:apply_highlights(default_highlight)
		self:apply_section_separators()
		return self.status
	end

	-- section_separators = { left = "", right = "" },
	local left_sep = ""
	local right_sep = ""

	-- Put proper separators and gaps between components in sections
	local function process_sections(sections)
		for name, section in pairs(sections) do
			local is_left = name:sub(9, 10) < "x"

			for pos = 1, name ~= "lualine_z" and #section or #section - 1 do
				table.insert(section, pos * 2, { empty, color = { bg = colors.white } })
			end

			for id, comp in ipairs(section) do
				if type(comp) ~= "table" then
					comp = { comp }
					section[id] = comp
				end

				comp.separator = is_left and { right = left_sep } or { left = right_sep }
			end
		end
		return sections
	end

	local function search_result()
		if vim.v.hlsearch == 0 then
			return ""
		end
		local last_search = vim.fn.getreg("/")
		if not last_search or last_search == "" then
			return ""
		end
		local searchcount = vim.fn.searchcount({ maxcount = 9999 })
		return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
	end

	local function is_visual_or_select_mode()
		local mode = vim.fn.mode()
		return mode == "v" or mode == "V" or mode == "\22" or mode == "s" or mode == "S" or mode == "\19"
	end

	local function byte_col_to_char_col(line, byte_col)
		if byte_col <= 1 then
			return 1
		end

		return vim.fn.strchars(line:sub(1, byte_col - 1)) + 1
	end

	local function count_region_chars(region)
		if #region == 0 then
			return 0
		end

		local count = #region - 1
		for _, line in ipairs(region) do
			count = count + vim.fn.strchars(line)
		end

		return count
	end

	local function selection_region_from_positions(mode)
		local start_pos = vim.fn.getpos("v")
		local end_pos = vim.fn.getpos(".")
		local start_line = start_pos[2]
		local start_col = start_pos[3]
		local end_line = end_pos[2]
		local end_col = end_pos[3]

		if start_line == 0 or end_line == 0 then
			return {}
		end

		if start_line > end_line or start_line == end_line and start_col > end_col then
			start_line, end_line = end_line, start_line
			start_col, end_col = end_col, start_col
		end

		local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
		if mode == "V" or mode == "S" then
			return lines
		end

		if mode == "\22" or mode == "\19" then
			local left_col = math.min(start_col, end_col)
			local right_col = math.max(start_col, end_col)
			local region = {}

			for _, line in ipairs(lines) do
				local line_chars = vim.fn.strchars(line)
				local left_char = byte_col_to_char_col(line, left_col)
				local right_char = math.min(byte_col_to_char_col(line, right_col), line_chars)
				if left_char <= right_char then
					table.insert(region, vim.fn.strcharpart(line, left_char - 1, right_char - left_char + 1))
				else
					table.insert(region, "")
				end
			end

			return region
		end

		if #lines == 1 then
			local left_char = byte_col_to_char_col(lines[1], start_col)
			local right_char = byte_col_to_char_col(lines[1], end_col)
			return { vim.fn.strcharpart(lines[1], left_char - 1, right_char - left_char + 1) }
		end

		local first_char = byte_col_to_char_col(lines[1], start_col)
		local last_char = byte_col_to_char_col(lines[#lines], end_col)
		lines[1] = vim.fn.strcharpart(lines[1], first_char - 1)
		lines[#lines] = vim.fn.strcharpart(lines[#lines], 0, last_char)

		return lines
	end

	local function selection_chars()
		if not is_visual_or_select_mode() then
			return ""
		end

		local mode = vim.fn.mode()
		local region_type = mode
		if mode == "s" then
			region_type = "v"
		elseif mode == "S" then
			region_type = "V"
		elseif mode == "\19" then
			region_type = "\22"
		end

		local region
		if vim.fn.exists("*getregion") == 1 then
			region = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), {
				type = region_type,
				exclusive = vim.o.selection == "exclusive",
			})
		else
			region = selection_region_from_positions(mode)
		end

		local count = count_region_chars(region)
		return count .. " " .. (count == 1 and "char" or "chars")
	end

	local function modified()
		if vim.bo.modified then
			return "+"
		elseif vim.bo.modifiable == false or vim.bo.readonly == true then
			return "-"
		end
		return ""
	end

	local function git_branch()
		if vim.b.large_file then
			return ""
		end

		return vim.b.gitsigns_head or ""
	end

	local function git_diff()
		if vim.b.large_file then
			return ""
		end

		local dict = vim.b.gitsigns_status_dict
		if not dict then
			return ""
		end

		local parts = {}
		if dict.added and dict.added > 0 then
			table.insert(parts, "+" .. dict.added)
		end
		if dict.changed and dict.changed > 0 then
			table.insert(parts, "~" .. dict.changed)
		end
		if dict.removed and dict.removed > 0 then
			table.insert(parts, "-" .. dict.removed)
		end

		return table.concat(parts, " ")
	end

	require("tokyonight").setup()

	require("lualine").setup({
		options = {
			theme = theme,
			component_separators = "",
			section_separators = { left = left_sep, right = right_sep },
		},
		sections = process_sections({
			lualine_a = { "mode" },
			lualine_b = {
				git_branch,
				git_diff,
				{
					"diagnostics",
					source = { "nvim" },
					sections = { "error" },
					diagnostics_color = { error = { bg = colors.red, fg = colors.white } },
				},
				{
					"diagnostics",
					source = { "nvim" },
					sections = { "warn" },
					diagnostics_color = { warn = { bg = colors.orange, fg = colors.white } },
				},
				{ "filename", file_status = false,        path = 1 },
				{ modified,   color = { bg = colors.red } },
				{
					"%w",
					cond = function()
						return vim.wo.previewwindow
					end,
				},
				{
					"%r",
					cond = function()
						return vim.bo.readonly
					end,
				},
				{
					"%q",
					cond = function()
						return vim.bo.buftype == "quickfix"
					end,
				},
			},
			lualine_c = {},
			lualine_x = {},
			lualine_y = { { selection_chars, cond = is_visual_or_select_mode }, search_result, "filetype", "filesize" },
			lualine_z = { "%l:%c", "%p%%/%L" },
		}),
		inactive_sections = {
			lualine_c = { "%f %y %m" },
			lualine_x = {},
		},
	})
end
