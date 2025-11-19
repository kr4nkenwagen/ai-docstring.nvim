local w = {}
function w.query_docstring(funct, language, win)
	if win == nil then
		local window_builder = require("ai-docstring.window")
		win = window_builder.create_output_window(window_builder.actions.DOCSTRING)

		win.set_language(language)
	end
	local config = require("ai-docstring").config
	local query = config.ai.prompt
	local docstring = require("ai-docstring.templates." .. language)
	query = query:gsub("$LANG", language)
	query = query:gsub("$TEMPLATE", docstring.docstring)
	query = query:gsub("$FUNC", funct)
	local cmd = {
		"ollama",
		"run",
		config.ai.model,
		'"' .. query .. '"',
	}
	local runner = require("ai-docstring.runner")
	runner.run_async(cmd, win)
end

function w.query_debug_lines(funct, language, win)
	if win == nil then
		local window_builder = require("ai-docstring.window")
		win = window_builder.create_output_window(window_builder.actions.DEBUG_LINES)
		win.set_language(language)
	end
	local config = require("ai-docstring").config
	local query =
		"This is a $LANG function. Write exstensive debug printlines. Use variables. Do not alter any of the logic or variable names. You are only allowed to use language standard print functions. Do not write extra functions. Don't import libraries. Write only the function. Don't assume things. \n $FUNC"
	local docstring = require("ai-docstring.templates." .. language)
	query = query:gsub("$LANG", language)
	query = query:gsub("$TEMPLATE", docstring.docstring)
	query = query:gsub("$FUNC", funct)
	local cmd = {
		"ollama",
		"run",
		config.ai.model,
		'"' .. query .. '"',
	}
	local runner = require("ai-docstring.runner")
	runner.run_async(cmd, win)
end

function w.query_function_explaination(funct, language, win)
	if win == nil then
		local window_builder = require("ai-docstring.window")
		win = window_builder.create_output_window(window_builder.actions.FUNCTION_EXPLAINATION)
		win.set_language("markdown")
	end
	local config = require("ai-docstring").config
	local query = "This is a $LANG function. explain its input, output and logic. Use markdown. \n $FUNC"
	local docstring = require("ai-docstring.templates." .. language)
	query = query:gsub("$LANG", language)
	query = query:gsub("$TEMPLATE", docstring.docstring)
	query = query:gsub("$FUNC", funct)
	local cmd = {
		"ollama",
		"run",
		config.ai.model,
		'"' .. query .. '"',
	}
	local runner = require("ai-docstring.runner")
	runner.run_async(cmd, win)
end

function w.clear_ai_chat(lines)
	local opener = -1
	local closer
	for i = 1, #lines, 1 do
		if opener == -1 then
			if string.find(lines[i], "```") then
				opener = i
			end
		else
			if string.find(lines[i], "```") then
				closer = i - opener
				break
			end
		end
	end
	if opener == -1 then
		return lines
	end
	for _ = 1, opener, 1 do
		table.remove(lines, 1)
	end
	for _ = closer, #lines, 1 do
		table.remove(lines, closer)
	end
	return lines
end

return w
