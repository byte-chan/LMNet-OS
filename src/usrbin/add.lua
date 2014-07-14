local tArgs = {...}

local function printUsage()
	print("Usage:")
	print("add /usr/bin <file>")
	print("add add bin <file>")
	print("add add program <file>")
	print("add apis <file>")
	print("add api <file>")
end

local function genFile()
	local file = shell.resolve(tArgs[2])
	if not fs.exists(file) then
		printError(file..": not found")
		return 1
	end
end

if tArgs < 2 then
	printUsage()
	return
end

if tArgs[1] == 'bin' or tArgs[1] == '/usr/bin' or tArgs[1] == 'program' then
	genFile()
	fs.copy(file,'/usr/bin/'..tArgs[2])
	print(file.." is now in /usr/bin.")
elseif tArgs[1] == 'apis' or tArgs[1] == 'api' then
	genFile()
	fs.copy(file,'/.lmnet/apis/'..tArgs[2])
	print(file.." is now an API.")
else
	error()
end
