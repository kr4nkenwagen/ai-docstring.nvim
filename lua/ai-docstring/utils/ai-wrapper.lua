local w = {}

function w.create_output_window()
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
function w.strip_ansi_colors(data)
	local function clean_line(str)
		return str
			-- Remove ANSI CSI sequences (e.g., ESC[31m, ESC[?25l)
			:gsub("\27%[[0-9;?]*[A-Za-z]", "")
			-- Remove OSC sequences (e.g., ESC]0;titleBEL)
			:gsub("\27%][0-9;]*.-\7", "")
			-- Remove DCS, PM, APC sequences
			:gsub("\27[P^_].-\27\\", "")
			:gsub("\r", "")
	end
	if type(data) == "table" then
		local cleaned = {}
		for i, line in ipairs(data) do
			cleaned[i] = clean_line(line)
		end
		return cleaned
	else
		return clean_line(data)
	end
end

function w.containsBraille(input)
	-- Pattern matches any character in the Braille Unicode block
	-- %z matches null bytes, so we use UTF-8 ranges
	-- Braille block: U+2800 to U+28FF
	local braille_pattern = "[\226\128\128-\226\131\191]" -- UTF-8 encoding of U+2800–U+28FF

	-- If input contains a Braille character, return true
	for _, str in ipairs(input) do
		if str:match(braille_pattern) then
			return true
		end
	end
	return false
end

function w.run_async(cmd)
	local buf, win = w.create_output_window()
	----------------vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Running: " .. table.concat(cmd, " ") })
	vim.fn.jobstart(cmd, {
		stdout_buffered = false,
		stderr_buffered = true,
		pty = true,
		on_stdout = function(_, data, _)
			if data then
				vim.schedule(function()
					if w.containsBraille(data) then
					else
						local last_line = vim.api.nvim_buf_line_count(buf) - 1
						local clean_text = w.strip_ansi_colors(data)
						local last_col = #(vim.api.nvim_buf_get_lines(buf, last_line, last_line + 1, false)[1] or "")
						vim.api.nvim_buf_set_text(buf, last_line, last_col, last_line, last_col, clean_text)
					end
				end)
			end
		end,
		on_stderr = function(_, data, _)
			if data then
				vim.schedule(function()
					local lines = {}
					for _, line in ipairs(data) do
						table.insert(lines, "ERR: " .. line)
					end
					vim.api.nvim_buf_set_lines(buf, 1, -1, false, lines)
				end)
			end
		end,
		on_exit = function(_, exit_code, _)
			vim.schedule(function()
				if exit_code ~= 0 then
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "Process exited with code " .. exit_code })
				end
			end)
		end,
	})
end

function w.ask(question)
	local cmd = {
		"ollama",
		"run",
		"llama3.2",
		'"You are a senior developer tasked with writing a docstring for the following funcion. Only write the docstring. Nothing else. do not write code. '
			.. question
			.. '"',
	}
	w.run_async(cmd)
end

return w
