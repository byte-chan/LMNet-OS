local tArgs = {...}
if #tArgs < 1 then
	print("Usage: rm <path>")
	return
end

local dir = tArgs[1]
if dir:sub(1, 1) == "~" then
	dir = "/"..(currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser))..dir:sub(2)
end
local sPath = shell.resolve(dir)
if fs.find then
	local tFiles = fs.find(sPath)
	if #tFiles > 0 then
		for n,sFile in ipairs(tFiles) do
			fs.delete(sFile)
		end
	else
		printError("No matching files")
	end
else
	if fs.exists(sPath) then
		fs.delete(sPath)
	else
		printError("File not found")
	end
end