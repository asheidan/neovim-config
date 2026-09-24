-- Heavily inspired by https://github.com/tjdevries/advent-of-nvim/blob/master/nvim/plugin/floaterminal.lua
local M = {}

-- vim.cmd([[put=execute('tags')]])

local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

local AUTOGROUP_NAME = "TagStackUpdate"

local function create_floating_window(opts)
	opts = opts or {}

	local width = opts.width or 40
	local height = opts.height or 10

	-- Create the buffer
	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
		vim.api.nvim_set_option_value("filetype", "tagstack", { buf = buf })
	end

	-- Calculate window position (top right)
	local col = vim.o.columns - 1
	local row = 1 -- vim.o.lines - 2  -- Under tabbar

	-- Define window configuration
	local window_config = {
		relative = "editor",
		anchor = "NE",

		width = width,
		height = height,

		col = col,
		row = row,

		style = "minimal", -- No borders of extra ui elements
		border = "rounded",

		title = { { " Tagstack ", "FloatBorder" } },
		title_pos = "center",
	}

	-- Create the floating window
	local win = vim.api.nvim_open_win(buf, false, window_config)
	vim.api.nvim_set_option_value("wrap", false, { win = win })

	return { buf = buf, win = win, opts = { width = width } }
end

local function format_item(item)
	local bufnr = item.from[1]

	local line_number = item.from[2]

	local line = ""
	local file_info = ""
	if vim.api.nvim_buf_is_valid(bufnr) then
		-- The line number is from 1 in the item and not from 0 as required by nvim_buf_get_lines
		line = vim.api.nvim_buf_get_lines(bufnr, line_number - 1, line_number, true)[1]
		line = string.gsub(line, "^%s+", "") -- Strip leading whitespace
		-- TODO: If the line is long, show the part of the line where the cursor was

		file_info = vim.api.nvim_buf_get_name(bufnr)
		file_info = vim.fn.fnamemodify(file_info, ":~:.") .. ":" .. line_number

		-- The window has a border around it so the available width is 2 less than the window
		local buf_width = state.floating.opts.width - 2
		if string.len(file_info) > (buf_width - 3) then
			file_info = "…" .. string.sub(file_info, -buf_width + 2)
		end
	end

	return { " " .. line, "   " .. file_info }
end

local function update_buf_content(ev)
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		print("Window is invalid", state.floating.win)

		return
	end

	if not vim.api.nvim_buf_is_valid(state.floating.buf) then
		print("Buffer is invalid", state.floating.buf)

		return
	end

	-- Stack content
	local data = vim.fn.gettagstack(0)
	-- vim.print(data)

	local lines = {}
	for _, item in pairs(data["items"]) do
		vim.list_extend(lines, format_item(item))
		-- This is probably where extmarks needs to be added to indicate which symbol we jumped to
	end

	-- New content
	vim.fn.setbufline(state.floating.buf, 1, lines)

	-- Remove any old lines still left
	if vim.api.nvim_buf_line_count(state.floating.buf) > 1 then
		vim.fn.deletebufline(state.floating.buf, #lines + 1, "$")
	end
end

local function create_updatecommands()
	local group = vim.api.nvim_create_augroup(AUTOGROUP_NAME, { clear = true })

	-- TODO: What to do when changing buffers, windows, and so on...

	-- CursorMoved - I might have to use this for detecting jumps within the same file
	-- CursorHold - Seems a bit too slow (4000ms)
	-- BufEnter, BufWinEnter - Might be enough, but doesn't seem so
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = group,
		pattern = "*",
		callback = update_buf_content,
	})
end

M.toggle_stack_window = function()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window({ buf = state.floating.buf })

		-- Setup autocmds to update the window when needed
		create_updatecommands()

		-- Populate the buffer
		update_buf_content()
	else
		vim.api.nvim_win_hide(state.floating.win)
		-- state.floating.win = -1
		vim.api.nvim_del_augroup_by_name(AUTOGROUP_NAME)
	end
end

return M
