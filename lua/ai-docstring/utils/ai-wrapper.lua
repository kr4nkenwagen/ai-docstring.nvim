local w = {}
function w.query(question, language)
	local config = require("ai-docstring").config
	local docstring = require("ai-docstring.templates." .. language)
	local cmd = {
		"ollama",
		"run",
		config.ai.model,
		'"' .. config.ai.system:gsub("$LANG", language):gsub("$TEMPLATE", docstring) .. " " .. question .. '"',
	}
	local window = require("ai-docstring.window")
	local runner = require("ai-docstring.runner")
	runner.run_async(cmd, window.create_output_window())
end

return w
