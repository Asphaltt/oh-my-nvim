--[[
 * SPDX-License-Identifier: MIT
 * Copyright 2024 Leon Hwang
]]

local M = {}

-- Get SPDX license list
local function get_spdx_licenses()
	local cache_file = vim.fn.stdpath("cache") .. "/spdx_licenses.json"
	local licenses = {}

	local function parse_licenses(content)
		local json = vim.fn.json_decode(content)
		if json and json.licenses then
			for _, license in ipairs(json.licenses) do
				licenses[license.licenseId] = license
			end
		end
	end

	local function update_cache()
		local handle = io.popen("curl -s https://spdx.org/licenses/licenses.json")
		if handle then
			local result = handle:read("*a")
			handle:close()
			local file = io.open(cache_file, "w")
			if file then
				file:write(result)
				file:close()
			end
			parse_licenses(result)
		end
	end

	local file = io.open(cache_file, "r")
	if file then
		local content = file:read("*a")
		file:close()
		local file_info = vim.loop.fs_stat(cache_file)
		if file_info and os.time() - file_info.mtime.sec > 86400 then
			update_cache()
		else
			parse_licenses(content)
		end
	else
		update_cache()
	end

	return licenses
end

-- Validate if the license ID is valid
local function validate_license_id(license_id)
	local licenses = get_spdx_licenses()
	return licenses[license_id] ~= nil
end

-- Define function to get comment style for file type
local function get_comment_style(filetype)
	local comment_styles = {
		ada = { "--", "--" },
		arduino = { "//", "//" },
		asm = { ";", ";" },
		c = { "/*", " */", true },
		cfg = { "#", "#" },
		clojure = { ";", ";" },
		coldfusion = { "<!---", "--->", true },
		cpp = { "/**", " */", true },
		cs = { "//", "//" },
		cuda = { "//", "//" },
		css = { "/*", " */" },
		dart = { "//", "//" },
		dosini = { ";", ";" },
		elixir = { "#", "#" },
		erlang = { "%", "%" },
		go = { "//", "//" },
		groovy = { "//", "//" },
		haskell = { "{-", "-}" },
		java = { "//", "//" },
		javascript = { "//", "//" },
		jsx = { "//", "//" },
		kotlin = { "//", "//" },
		less = { "//", "//" },
		lex = { "/*", " */" },
		lisp = { ";", ";" },
		lua = { "--[[", "]]", true },
		make = { "#", "#" },
		markdown = { "<!--", "-->", true },
		matlab = { "%", "%" },
		octave = { "%", "%" },
		ocaml = { "(*", "*)" },
		perl = { "#", "#" },
		php = { "/*", " */" },
		plaintex = { "%", "%" },
		pug = { "//", "//" },
		proto = { "//", "//" },
		python = { "#", "#" },
		racket = { ";", ";" },
		rst = { ".. ", "" },
		ruby = { "#", "#" },
		rust = { "//", "//" },
		sass = { "//", "//" },
		scala = { "//", "//" },
		scheme = { ";", ";" },
		sh = { "#", "#" },
		svelte = { "<!--", "-->", true },
		tcl = { "#", "#" },
		tex = { "%", "%" },
		tmux = { "#", "#" },
		tsx = { "//", "//" },
		vhdl = { "--", "--" },
		verilog = { "//", "//" },
		vim = { '"', '"' },
		xdefaults = { "!", "!" },
		yacc = { "/*", " */", true },
		yaml = { "#", "#" },
		vimwiki = { "<!--", "-->", true },
	}
	return comment_styles[filetype] or { "#", "#" }
end
-- Define function to detect license from LICENSE file
local function detect_license_from_file()
	local license_file = io.open("LICENSE", "r")
	if not license_file then
		print("Error: LICENSE file not found in the current working directory")
		return nil
	end

	local content = license_file:read("*all")
	license_file:close()

	-- Get SPDX licenses
	local spdx_licenses = get_spdx_licenses()

	-- Function to fetch license text from detailsUrl or cache
	local function fetch_license_text(license_id, details_url)
		local cache_dir = vim.fn.stdpath("cache") .. "/spdx_licenses"
		local cache_file = cache_dir .. "/" .. license_id .. ".txt"

		-- Try to read from cache first
		local file = io.open(cache_file, "r")
		if file then
			local cached_text = file:read("*all")
			file:close()
			return cached_text
		end

		-- If not in cache, fetch from URL
		local handle = io.popen("curl -s " .. details_url)
		if handle then
			local result = handle:read("*a")
			handle:close()
			local json = vim.fn.json_decode(result)
			local license_text = json and json.licenseText

			-- Cache the license text
			if license_text then
				vim.fn.mkdir(cache_dir, "p")
				file = io.open(cache_file, "w")
				if file then
					file:write(license_text)
					file:close()
				end
			end

			return license_text
		else
			vim.cmd('echon ""')
			print(string.format("Failed to fetch %s license", license_id))
		end
		return nil
	end

	-- Check for license match using licenseText
	for license_id, license_info in pairs(spdx_licenses) do
		local license_text = fetch_license_text(license_id, license_info.detailsUrl)
		if license_text then
			-- Remove whitespace and convert to lowercase for comparison
			local normalized_license_text = license_text:gsub("%s+", ""):lower()
			local normalized_content = content:gsub("%s+", ""):lower()

			if normalized_content:find(normalized_license_text, 1, true) then
				return license_id
			end
		end
	end

	print("Error: Unable to detect license from LICENSE file")
	return nil
end
-- Define function to insert SPDX header
function M.insert_spdx_header()
	local license_id = detect_license_from_file()
	if not license_id then
		return
	end

	if not validate_license_id(license_id) then
		print("Error: Detected license ID is not a valid SPDX license ID")
		return
	end

	local author = vim.g.spdx_author
	if not author or author == "" then
		print("Error: vim.g.spdx_author is not set")
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[bufnr].filetype
	local comment_start, comment_end, block_style = unpack(get_comment_style(filetype))
	block_style = block_style or false

	local current_year = os.date("%Y")

	local spdx_header
	if block_style then
		spdx_header = string.format(
			[[
%s
 * SPDX-License-Identifier: %s
 * Copyright %s %s
%s
]],
			comment_start,
			license_id,
			current_year,
			author,
			comment_end
		)
	else
		spdx_header = string.format(
			[[
%s SPDX-License-Identifier: %s
%s Copyright %s %s
]],
			comment_start,
			license_id,
			comment_start,
			current_year,
			author
		)
	end

	-- Check if SPDX header already exists
	local first_seven_lines = vim.api.nvim_buf_get_lines(bufnr, 0, 7, false)
	for _, line in ipairs(first_seven_lines) do
		if line:match("SPDX%-License%-Identifier") then
			print("SPDX header already exists. Skipping insertion.")
			return
		end
	end

	-- Insert SPDX header at the beginning of the file
	vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, vim.split(spdx_header, "\n"))
end

-- Create user command
vim.api.nvim_create_user_command("SPDXInsert", M.insert_spdx_header, {})

-- Function to download license text and save to LICENSE file
local function download_license(license_id)
	local curl_command = string.format("curl -s https://spdx.org/licenses/%s.txt > LICENSE", license_id)
	local success = os.execute(curl_command)

	vim.cmd('echon ""')
	if success then
		print(string.format("%s License downloaded and saved to LICENSE file.", license_id))
	else
		print("Error: Failed to download license.")
	end
end

-- Function to complete license IDs
function M.complete_license_ids(arglead, cmdline, cursorpos)
	local matches = {}
	local license_ids = get_spdx_licenses()
	for id, _ in pairs(license_ids) do
		if id:lower():find(arglead:lower(), 1, true) == 1 then
			table.insert(matches, id)
		end
	end
	table.sort(matches)
	return matches
end

-- Create user command for downloading license
vim.api.nvim_create_user_command("SPDXDownloadLicense", function()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local licenses = get_spdx_licenses()
	local license_list = {}
	for id, _ in pairs(licenses) do
		table.insert(license_list, id)
	end
	table.sort(license_list)

	pickers
		.new({}, {
			prompt_title = "Select SPDX License",
			finder = finders.new_table({
				results = license_list,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local license_id = selection[1]
					download_license(license_id)
				end)
				return true
			end,
		})
		:find()
end, {})

-- Function to set up plugin configuration
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
