local play = "term.clear()\nterm.setCursorPos(1,1)\npos = 1\nstart = os.clock()\nwhile true do\n	if str[pos][1] <= os.clock() - start then\n  term[str[pos][2]](unpack(str[pos][3]))\n  pos = pos + 1\n  if pos == #str then\n    break\n  end\n	else\n		sleep(0.01)\n	end\nend\nsleep(2)\nterm.clear()\nterm.setCursorPos(1,1)\nprint('Recording Ended!')"
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

ntv.clear()
ntv.setCursorPos(1, 1)
term.redirect(redirect)

if tArgs[2] == nil or not fs.exists(shell.resolve(tArgs[2])) then
  if fs.exists("startup") then
  	tArgs[2] = "startup"
  end
end
shell.run(shell.resolve(tArgs[2]))

term.redirect(term.native())
term.native().clear()
term.native().setCursorPos(1, 1)
print("Please wait... Saving")
f = fs.open(tArgs[1],"wb")
rec = textutils.serialize(rec)
rec = "str = "..rec.."\n"..play
for i=1,#rec do
	f.write(string.byte(rec:sub(i,i)))
	if i%1000 == 0 then
		sleep(0)
	end
end
f.close()