if not git then
	printError("Git API not loaded")
	return
end

if not git.get then
	printError("Git get function not found")
	return
end

local function printUsage()
	print("Usage:")
	print("git get <user> <repo> <branch> <file> <save>")
	print("git run <user> <repo> <branch> <file>")
end

local tArgs = {...}
if #tArgs < 1 then
	printUsage()
	return
end

local mode = tArgs[1]
if mode == "get" then
	if #tArgs < 6 then
		printUsage()
		return
	end
	local user = tArgs[2]
	local repo = tArgs[3]
	local bran = tArgs[4]
	local path = tArgs[5]
	local save = tArgs[6]
	local ok = git.get(user, repo, bran, path, save)
	if not ok then
		printError("Error getting file")
		return
	end
	print("File saved as "..save)
elseif mode == "run" then
	if #tArgs < 5 then
		printUsage()
		return
	end
	local user = tArgs[2]
	local repo = tArgs[3]
	local bran = tArgs[4]
	local path = tArgs[5]
	local ok = git.get(user, repo, bran, path)
	if not ok then
		printError("Error getting file")
		return
	end
	local func = setfenv(loadstring(ok), getfenv())
	local func_ok, func_err = pcall(func)
	if not func_ok then
		printError(func_err)
	end
else
	printUsage()
	return
end