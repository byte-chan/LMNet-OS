local tArgs = {...}
if #tArgs < 1 then
	print("Usage: record <file> [startup]")
	return
end

local w, h = term.native().getSize()
local ntv = term.native()
rec = {}
start = os.clock()
local redirect = {
	setCursorPos = function(...)
		rec[#rec + 1] = {}
		rec[#rec][1] = os.clock() - start
		rec[#rec][2] = "setCursorPos"
		rec[#rec][3] = {...}
		ntv.setCursorPos(...)
	end,
	getCursorPos = function(...)
		return ntv.getCursorPos(...)
	end,
	getSize = function(...)
		return ntv.getSize(...)
	end,
	write = function(...)
		rec[#rec + 1] = {}
		rec[#rec][1] = os.clock() - start
		rec[#rec][2] = "write"
		rec[#rec][3] = {...}
		ntv.write(...)
	end,
	scroll = function(...)
		rec[#rec + 1] = {}
		rec[#rec][1] = os.clock() - start
		rec[#rec][2] = "scroll"
		rec[#rec][3] = {...}
		ntv.scroll(...)
	end,
	clear = function(...)
		rec[#rec + 1] = {}
		rec[#rec][1] = os.clock() - start
		rec[#rec][2] = "clear"
		rec[#rec][3] = {...}
		ntv.clear(...)
	end,
	clearLine = function(...)
		rec[#rec + 1] = {}
		rec[#rec][1] = os.clock() - start
		rec[#rec][2] = "clearLine"
		rec[#rec][3] = {...}
		ntv.clearLine(...)
	end,
	setCursorBlink = function(...)
		rec[#rec + 1] = {}
		rec[#rec][1] = os.clock() - start
		rec[#rec][2] = "setCursorBlink"
		rec[#rec][3] = {...}
		ntv.setCursorBlink(...)
	end,
	isColor = ntv.isColor,
	setTextColor = function(...)
		rec[#rec + 1] = {}
		rec[#rec][1] = os.clock() - start
		rec[#rec][2] = "setTextColor"
		rec[#rec][3] = {...}
		ntv.setTextColor(...)
	end,
	setBackgroundColor = function(...)
		rec[#rec + 1] = {}
		rec[#rec][1] = os.clock() - start
		rec[#rec][2] = "setBackgroundColor"
		rec[#rec][3] = {...}
		ntv.setBackgroundColor(...)
	end,
}

redirect.isColour = redirect.isColor
redirect.setTextColour = redirect.setTextColor
redirect.setBackgroundColour = redirect.setBackgroundColor

term.native().clear()
term.native().setCursorPos(1, 1)
term.redirect(redirect)

if tArgs[2] == nil or not fs.exists(shell.resolve(tArgs[2])) then
  tArgs[2] = "shell"
end
shell.run(shell.resolve(tArgs[2]))

term.redirect(term.native())
term.native().clear()
term.native().setCursorPos(1, 1)
print("Please wait... Saving")
f = fs.open(tArgs[1],"w")
f.writeLine(textutils.serialize(rec))
f.close()