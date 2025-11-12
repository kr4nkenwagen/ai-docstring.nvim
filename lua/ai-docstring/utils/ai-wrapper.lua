local w = {}
function w.query(question, language, win)
	if win == nil then
		win = require("ai-docstring.window").create_output_window()
	end
	local config = require("ai-docstring").config
	local docstring = require("ai-docstring.templates." .. language)
	local cmd = {
		"ollama",
		"run",
		config.ai.model,
		'"' .. config.ai.system:gsub("$LANG", language):gsub("$TEMPLATE", docstring) .. " " .. question .. '"',
	}
	local runner = require("ai-docstring.runner")
	runner.run_async(cmd, win)
end

return w
