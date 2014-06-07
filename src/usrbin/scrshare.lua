local tArgs = {...}
if #tArgs < 1 then
	print("Usage: scrshare <monitor>")
	return
end

local mon = peripheral.wrap(tArgs[1])
if not mon then
	printError("Invalid monitor")
	return
end

mon.setBackgroundColor(colors.gray)
mon.clear()

local w, h = term.native().getSize()
local win = window.create(mon, 1, 1, w, h, true)
local ntv = term.native()

local redirect = {
	setCursorPos = function(...)
		win.setCursorPos(...)
		ntv.setCursorPos(...)
	end,
	getCursorPos = function(...)
		return ntv.getCursorPos(...)
	end,
	getSize = function(...)
		return ntv.getSize(...)
	end,
	write = function(...)
		win.write(...)
		ntv.write(...)
	end,
	scroll = function(...)
		win.scroll(...)
		ntv.scroll(...)
	end,
	clear = function(...)
		win.clear(...)
		ntv.clear(...)
	end,
	clearLine = function(...)
		win.clearLine(...)
		ntv.clearLine(...)
	end,
	setCursorBlink = function(...)
		win.setCursorBlink(...)
		ntv.setCursorBlink(...)
	end,
	isColor = function(...)
		return (win.isColor(...) and ntv.isColor(...))
	end,
	setTextColor = function(...)
		win.setTextColor(...)
		ntv.setTextColor(...)
	end,
	setBackgroundColor = function(...)
		win.setBackgroundColor(...)
		ntv.setBackgroundColor(...)
	end,
}

redirect.isColour = redirect.isColor
redirect.setTextColour = redirect.setTextColor
redirect.setBackgroundColour = redirect.setBackgroundColor

term.native().clear()
term.native().setCursorPos(1, 1)
term.redirect(redirect)

shell.run(fs.exists("usr/bin/bash") and "/usr/bin/bash" or "shell")

term.redirect(term.native())
term.native().clear()
term.native().setCursorPos(1, 1)
if term.native().isColor() then
 term.setTextColor(colors.yellow)
end
print(os.version())
term.native().setTextColor(colors.white)
mon.clear()
mon.setCursorPos(1, 1)
mon.setCursorBlink(false)