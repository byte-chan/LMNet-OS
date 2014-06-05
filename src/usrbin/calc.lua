local input = ""
local running = true

local buttons = {
	{"<",  2,  4},                {"c",  6,  4},                {"x", 10,  4},
	{"7",  2,  6}, {"8",  4,  6}, {"9",  6,  6}, {"/",  8,  6},
	{"4",  2,  8}, {"5",  4,  8}, {"6",  6,  8}, {"*",  8,  8},
	{"1",  2, 10}, {"2",  4, 10}, {"3",  6, 10}, {"-",  8, 10},
	{"0",  2, 12},                {".",  6, 12}, {"+",  8, 12}, {"=", 10, 12},
}

local handle = {
	["<"] = function()
		if input:len() > 0 then
			input = input:sub(1, input:len()-1)
		end
	end,
	["c"] = function()
		input = ""
	end,
	["="] = function()
		ok, out = pcall(loadstring("return "..input.." or \"ERROR\"", "calc"))
		if not ok then input = "ERROR" else input = tostring(out) end
	end,
	["x"] = function() running = false end
}

local function detectClick()
	local e = {os.pullEvent()}
	if e[1] == "mouse_click" and e[2] == 1 then
		local x, y = e[3], e[4]
		for _, btn in pairs(buttons) do
			if x == btn[2] and y == btn[3] then
				if handle[btn[1]] then
					handle[btn[1]]()
				else
					input = input..btn[1]
				end
			end
		end
	elseif e[1] == "char" then
		input = input..e[2]
	elseif e[1] == "key" then
		if e[2] == keys.backspace then
			handle["<"]()
		elseif e[2] == keys.enter then
			handle["="]()
		elseif e[2] == keys.delete then
			handle["c"]()
		end
	end
end

local function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

local function redraw()
	clear()
	for _, btn in pairs(buttons) do
		term.setCursorPos(btn[2], btn[3])
		write(btn[1])
	end
	term.setCursorPos(2, 2)
	write(input)
end

while running do
	input = tostring(input)
	redraw()
	detectClick()
	clear()
end