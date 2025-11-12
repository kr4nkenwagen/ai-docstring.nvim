local w = {}
function w.query(question, language, win)
	if win == nil then
		win = require("ai-docstring.window").create_output_window()
	end
	local config = require("ai-docstring").config
	local system = config.ai.system
	local docstring = require("ai-docstring.templates." .. language)
	system = system:gsub("$LANG", language)
	system = system:gsub("$TEMPLATE", docstring.docstring)
	local cmd = {
		"ollama",
		"run",
		config.ai.model,
		'"' .. system .. " " .. question .. '"',
	}
	local runner = require("ai-docstring.runner")
	runner.run_async(cmd, win)
end

return w
