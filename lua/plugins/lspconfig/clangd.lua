local clangd
local latest_version = -1
for _, path in ipairs(vim.fn.glob("/usr/lib/llvm-*/bin/clangd", false, true)) do
	local version = tonumber(path:match("/llvm%-(%d+)/bin/clangd$"))
	if version and version > latest_version and vim.fn.executable(path) == 1 then
		clangd = path
		latest_version = version
	end
end

if not clangd then
	return false
end

return {
	cmd = {
		clangd,
		"--background-index",
		"-j=" .. vim.trim(vim.fn.system("nproc")),
		"--query-driver=/usr/bin/gcc,/usr/bin/*-gcc-*",
	},
	root_markers = { ".clangd" },
	workspace_required = true,
}
