tArgs = { ... }

function error()
	printError("add /usr/bin <file>")
	printError(" -> add bin <file>")
	printError("add apis <file>")
end

function genFile()
	file = shell.resolve(tArgs[2])
	if not fs.exists(file) then
		printError("file didn\'t exists!")
		return
	end
end

if tArgs < 2 then
	error()
	return
end

if tArgs[1] == 'bin' or tArgs[1] == '/usr/bin' then
	genFile()
	fs.copy(file,'/usr/bin/'..tArgs[2])
	print(file.." is now in /usr/bin")
elseif tArgs[1] == 'apis' then
	genFile()
	fs.copy(file,'/.lmnet/apis/'..tArgs[2])
	print(file.." is now an API!")
else
	error()
end
