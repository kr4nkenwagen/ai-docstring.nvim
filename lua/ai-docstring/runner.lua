local r = {}

function r.run_async(cmd, win)
	if cmd ~= nil then
		r.buf = win.buf
		r.cmd = cmd
		r.win = win
		r.win.cmd = cmd
	end
	r.id = vim.fn.jobstart(cmd, {
		stdout_buffered = false,
		stderr_buffered = true,
		pty = true,
		on_stdout = r.on_stdout,
		on_stderr = r.on_stderr,
		on_exit = r.on_exit,
	})
	vim.fn.jobresize(r.id, r.win.width, r.win.height)
	if win ~= nil then
		r.win.runner = r.id
	end
end

function r.on_stdout(_, data, _)
	if data then
		if vim.api.nvim_buf_is_loaded(r.buf) == false then
			vim.fn.jobstop(r.id)
			return
		end
		vim.schedule(function()
			local last_line = vim.api.nvim_buf_line_count(r.buf) - 1
			local last_line_content = vim.api.nvim_buf_get_lines(r.buf, last_line, last_line + 1, false)[1]
			if require("ai-docstring.utils.chars").containsBraille(last_line_content:sub(-2)) then
				vim.api.nvim_buf_set_lines(r.buf, last_line, last_line + 1, false, {})
				last_line = last_line - 1
			end
			local clean_text = require("ai-docstring.utils.chars").strip_ansi_colors(data)
			local last_col = #(vim.api.nvim_buf_get_lines(r.buf, last_line, last_line + 1, false)[1] or "")
			vim.api.nvim_buf_set_text(r.buf, last_line, last_col, last_line, last_col, clean_text)
		end)
	end
end

function r.on_stderr(_, data, _)
	if data then
		vim.schedule(function()
			local lines = {}
			for _, line in ipairs(data) do
				table.insert(lines, "ERR: " .. line)
			end
			vim.api.nvim_buf_set_lines(r.buf, 1, -1, false, lines)
		end)
	end
end

function r.stop()
	vim.fn.jobstop(r.id)
end

function r.on_exit(_, exit_code, _)
	if r.win.action == r.win.actions.FUNCTION_EXPLAINATION then
		return
	end
	local lines = r.win.get_buffer_text()
	lines = require("ai-docstring.utils.ai-wrapper").clear_ai_chat(lines)
	if r.win.action == r.win.actions.DOCSTRING then
		lines = require("ai-docstring").load_language_module().post_process(lines)
	end
	r.win.set_buffer_text(lines)
end

return r
