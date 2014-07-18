local function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

clear()
print("Installing rdnt-srv will overwrite the current startup file.")
write("Install rdnt-srv on this machine? [yN] ")
local input = string.lower(read())
if input ~= "y" then
	return
end
local urlOK = false
while not urlOK do
	clear()
	print("rdnt-srv")
	print("Server software for rdnt")
	print(status)
	write("Enter URL: ")
	local input = read()
	for _, v in pairs(rs.getSides()) do
		if peripheral.getType(v) == "modem" then
			rednet.open(v)
		end
	end
	rednet.broadcast(input)
	local e = {rednet.receive(3)}
	if e[1] ~= nil then
		status = "The URL '"..input.."'is already in use."
	else
		urlOK = true
		local file = fs.open(".lmnet/rdnt-srv.conf", "w")
		file.write("url=\""..input.."\"")
		file.close()
	end
end

local remote = http.get("https://raw.github.com/MultHub/LMNet-OS/extra/rdnt-server.lua")
if remote then
	local file = fs.open(".lmnet/rdnt-server.lua", "w")
	file.write(remote.readAll())
	file.close()
	remote.close()
end
if not fs.exists(".lmnet/rdnt-server.lua") then
	printError("Error installing rdnt-srv.")
	printError("Please try again later.")
	return
end

if fs.exists("startup") then
	if fs.exists("startup.rdntbak") then
		fs.delete("startup.rdntbak")
	end
	fs.move("startup", "startup.rdntbak")
end
fs.copy(".lmnet/rdnt-server.lua", "startup")

print("rdnt-srv installed. Create the file 'site' if it doesn't exist.")
