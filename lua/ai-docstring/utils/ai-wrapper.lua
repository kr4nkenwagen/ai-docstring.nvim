local w = {}
function w.query(funct, language, win)
	if win == nil then
		win = require("ai-docstring.window").create_output_window()
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

return w
