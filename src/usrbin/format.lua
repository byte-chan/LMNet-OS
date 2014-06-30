tArgs = { ... }

if #tArgs < 1 then
	printError("format <path>")
	return
end

local path = shell.resolve(tArgs[1])
if not fs.exists(path) then
	printError("Path didn\'t exists")
	return
end

local list = fs.list(path)
term.clear()
term.setCursorPos(1,1)
print("Really delete all files in "..path.." ?")
print("[yN]")
local input = read():lower()
if input == 'y' then
	for i=1,#list do
		fs.delete(path..list[i])
		print("Delete: "..list[i])
	end
	print(path.."is empty")
else
	print("exit...")
	return
end
