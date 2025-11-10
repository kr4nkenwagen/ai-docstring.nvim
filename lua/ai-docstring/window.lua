local w = {}
function w.create_output_window()
	local config = require("ai-docstring").config
	local buf = vim.api.nvim_create_buf(false, true) -- unlisted, scratch buffer
	local current_buf = vim.api.nvim_get_current_buf() or 0
	local width = math.floor(vim.o.columns * 0.7)
	local height = math.floor(vim.o.lines * 0.5)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	vim.api.nvim_buf_create_user_command(buf, "YankAndPasteBuffer", function()
		-- Get all lines in buffer
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		for i = #lines, 1, -1 do
			local line = lines[i]
			if string.find(line, "```") or #line == 0 then
				table.remove(lines, i)
			end
		end
		table.insert(lines, 1, "")
		-- Close the buffer
		vim.api.nvim_buf_delete(buf, { force = true })

		-- Insert the yanked lines at cursor in current buffer
		local win = vim.api.nvim_get_current_win()
		local row, col = unpack(vim.api.nvim_win_get_cursor(win))
		row = row - 1
		vim.api.nvim_buf_set_text(0, row, col, row, col, lines)
	end, {})
	vim.api.nvim_buf_set_keymap(buf, "n", "<leader>", ":YankAndPasteBuffer<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q!<CR>", { noremap = true, silent = true })

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = "al-docstring | " .. config.ai.model,
		footer = config.accept_key .. ": Accept docstring | " .. config.decline_key .. ": Discard docstring",
	})

	return buf, win
end

function w.close_and_save(src, dest)
	local text = vim.api.nvim_buf_get_lines(src, 0, -1, false)
	vim.api.nvim_buf_delete(src, { force = true })
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1
	vim.api.nvim_buf_set_text(dest, row, col, row, col, text)
end
return w
