local modemsFound = false
for _, v in pairs(rs.getSides()) do
	if peripheral.getType(v) == "modem" then
		rednet.open(v)
		modemsFound = true
	end
end

if not modemsFound then
	printError("No modems attached")
	return
end

local tArgs = {...}
if #tArgs < 2 then
	print("Usage: netsend <file> <name>")
	return
end

if not fs.exists(tArgs[1]) then
	printError("File not found")
	return
end

if fs.isDir(tArgs[1]) then
	printError("Is a directory")
	return
end

local file = fs.open(tArgs[1], "r")
local str = file.readAll()
file.close()

rednet.broadcast(textutils.serialize({mode = "netfile", name = tArgs[2], content = str}))