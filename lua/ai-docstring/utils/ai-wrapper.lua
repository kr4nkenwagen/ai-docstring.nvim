local w = {}

function w.run_async(cmd, buf, win)
	w.id = vim.fn.jobstart(cmd, {
		stdout_buffered = false,
		stderr_buffered = true,
		pty = true,
		on_stdout = function(_, data, _)
			if data then
				if vim.api.nvim_buf_is_loaded(buf) == false then
					vim.fn.jobstop(w.id)
					return
				end
				vim.schedule(function()
					local last_line = vim.api.nvim_buf_line_count(buf) - 1
					local last_line_content = vim.api.nvim_buf_get_lines(buf, last_line, last_line + 1, false)[1]
					if w.containsBraille(last_line_content:sub(-2)) then
						vim.api.nvim_buf_set_lines(buf, last_line, last_line + 1, false, {})
						last_line = last_line - 1
					end
					local clean_text = w.strip_ansi_colors(data)
					local last_col = #(vim.api.nvim_buf_get_lines(buf, last_line, last_line + 1, false)[1] or "")
					vim.api.nvim_buf_set_text(buf, last_line, last_col, last_line, last_col, clean_text)
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
		on_exit = function(_, exit_code, _) end,
	})
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
	return input:match(braille_pattern)
end

function w.query(question)
	local config = require("ai-docstring").config
	local cmd = {
		"ollama",
		"run",
		config.ai.model,
		'"' .. config.ai.system .. " " .. question .. '"',
	}
	local window = require("ai-docstring.window")
	w.run_async(cmd, window.create_output_window())
end

return w
