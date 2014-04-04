local tArgs = {...}
if #tArgs < 1 then
	print("Usage: cat <file>")
	return
end

if fs then
	if not fs.exists(tArgs[1]) then
		fgSet(colors.red)
		print(tArgs[1]..": File not found")
		fgSet(colors.white)
	end
	local file = fs.open(tArgs[1], "r")
	print(file.readAll())
	file.close()
else
	local file = io.open(tArgs[1], "r")
	local line = true
	while line do
		local str = file:read()
		if str then
			print(str)
		else
			line = false
		end
	end
	file:close()
end