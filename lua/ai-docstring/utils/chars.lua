local c = {}

function c.strip_ansi_colors(data)
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

function c.containsBraille(input)
	-- Braille block: U+2800 to U+28FF
	local braille_pattern = "[\226\128\128-\226\131\191]"
	return input:match(braille_pattern)
end

return c
