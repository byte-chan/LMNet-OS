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

local filepath = shell.resolve(tArgs[1])

if not fs.exists(filepath) then
	printError("File not found")
	return
end

if fs.isDir(filepath) then
	printError("Is a directory")
	return
end

local file = fs.open(filepath, "r")
local str = file.readAll()
file.close()

rednet.broadcast(textutils.serialize({mode = "netfile", name = tArgs[2], content = str}))
print("File sent.")