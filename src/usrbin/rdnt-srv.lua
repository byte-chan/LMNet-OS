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
		url = input
	end
end

local code = [[
-- rdnt-srv
-- Server software for rdnt

for _, v in pairs(rs.getSides()) do
	if peripheral.getType(v) == "modem" then
		rednet.open(v)
	end
end

local url = "]]..url..[["


function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

function printLog(text)
	local time = textutils.formatTime(os.time(), true)
	print("["..string.rep(" ", 5-time:len())..time.."] "..text)
end

local file = fs.open("/site", "r")
local site = file.readAll()
file.close()

while true do
	local e = {rednet.receive()}
	if e[2]:sub(1, url:len()) == url and (e[2]:sub(url:len()+1, url:len()+1) == "" or e[2]:sub(url:len()+1, url:len()+1) == "/") then
		local f = {string.gsub(e[2], "[^/]+", "")}
		if f[2] > 1 then
			local str = ""
			for match in string.gmatch(e[2], "[^/]+") do
				if match ~= url then
					str = str.."/"..match
				end
			end
			printLog("ID "..e[1].." wants "..str)
			if fs.exists("/subsite"..str) then
				local file = fs.open("/subsite"..str, "r")
				rednet.send(e[1], file.readAll())
				file.close()
			else
				if fs.exists("/404") then
					local file = fs.open("/404", "r")
					rednet.send(e[1], file.readAll())
					file.close()
				else
					rednet.send(e[1], "print(\"404 Not Found\")\nprint(\"This file does not exist on this site.\")")
				end
					printLog("Reply to ID "..e[1]..": 404")
				end
			else
				rednet.send(e[1], site)
				printLog("ID "..e[1].." wants main site")
			end
		printLog("Request by ID "..e[1]..": success.")
	end
end
]]

local file = fs.open("startup", "w")
file.write(code)
file.close()

print("rdnt-srv installed. Create the file 'site' if")
print("it doesn't exist.")