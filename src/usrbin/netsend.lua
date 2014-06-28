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
if #tArgs < 1 then
	print("Usage: netsend <file> [<name>]")
	return
end

if tArgs[2] then
	local name = tArgs[2]
else
	local name = tArgs[1]
end

local filepath = shell.resolve(tArgs[1])

if not fs.exists(filepath) then
	printError("File not found")
	return
end

if fs.isDir(filepath) then
	local isDir = true
	local dirContent = fs.list(shell.resolve(tArgs[1]))
else
	local isDir = false
end

if isDir then
	local str = {}
	for i=1,#dirContent do
		local file = fs.open(shell.resolve(tArgs[1]..dirContent[i]),"r")
		local x = file.readAll()
		table.insert(str,x)
		file.close()
	end
	str = textutils.serialize(str)
	dirContent = textutils.serialize(dirContent)
	rednet.broadcast(textutils.serialize({mode = "netfileDIR", name = dirContent, content = str}))
	print("Dir "..name.." send.")
else
	local file = fs.open(filepath, "r")
	local str = file.readAll()
	file.close()

	rednet.broadcast(textutils.serialize({mode = "netfile", name = name, content = str}))
	print("File "..name.." sent.")
end