return {
    "leonhwang/tig",
    virtual = true,
    config = function()
        local function open_tig_float(n)
            -- 1. Build the command
            -- If n is provided, limit the range, otherwise open normally
            local cmd = "tig"
            if n and n ~= "" then
                cmd = string.format("tig HEAD~%s..HEAD", n)
            end

            -- 2. Window dimensions
            local width = math.floor(vim.o.columns * 0.9)
            local height = math.floor(vim.o.lines * 0.9)
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)

            -- 3. Create buffer and window
            local buf = vim.api.nvim_create_buf(false, true)
            local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = width,
                height = height,
                row = row,
                col = col,
                style = "minimal",
                border = "rounded",
            })

            -- 4. Run tig and auto-close
            vim.fn.termopen(cmd, {
                on_exit = function()
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                    end
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end
                end,
            })

            vim.cmd("startinsert")
        end

        -- Create a user command :Tig <n>
        vim.api.nvim_create_user_command("Tig", function(opts)
            open_tig_float(opts.args)
        end, { nargs = "?" })

        -- Default mapping for last 20 commits
        vim.keymap.set("n", "<leader>gt", ":Tig 20<CR>", {
            desc = "Tig (Last 20)",
            silent = true,
        })
    end,
}
