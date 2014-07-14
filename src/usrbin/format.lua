local tArgs = {...}

if #tArgs < 1 then
	printError("format <path>")
	return
end

local path = shell.resolve(tArgs[1])
if not fs.exists(path) then
	printError(path..": not found")
	return
end

local list = fs.list(path)
clear()
local format = ui.yesno("Really delete all files in "..path.."?\nTHIS CANNOT BE UNDONE!\n(unless you have backups)", "format", false)
if format then
	for i = 1, #list do
		local ok, err = pcall(fs.delete, fs.combine(path, list[i]))
		if ok then
			print("Deleted: "..list[i])
		else
			printError("Error deleting file "..list[i]..":")
			printError(err)
		end
	end
	print(path..": format successful.")
	return 0
else
	print("Aborting.")
	return 1
end
