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
-- rdnt-srv 1.1
-- Server software for rdnt

if not fs.exists("site") then
	term.clear()
	term.setCursorPos(1, 1)
	print("No main site found. Create the file 'site'.")
	return
end

local oldPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

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

clear()

function printLog(text)
	local time = textutils.formatTime(os.time(), true)
	print("["..string.rep(" ", 5-time:len())..time.."] "..text)
end

printLog("rdnt-srv 1.2: "..url)

local file = fs.open("/site", "r")
local site = file.readAll()
file.close()

while true do
	local e = {os.pullEvent()}
	local event = e[1]
	if event == "rednet_message" and type(e[3]) == "string" then
		local sender = e[2]
		local msg = e[3]
		local header = "local _DATA = {}\n"
		local tmp = {string.gsub(msg, "[^?]+", "")}
		if tmp[2] > 1 then
			local matches = {}
			for match in string.gmatch(msg, "[^?]+") do
				table.insert(matches, match)
			end
			local rawData = matches[2]
			local parts = {}
			for match in string.gmatch(rawData, "[^&]+") do
				table.insert(parts, match)
			end
			local data = {}
			for _, v in pairs(parts) do
				local subparts = {}
				for match in string.gmatch(v, "[^=]+") do
					table.insert(subparts, match)
				end
				local key = subparts[1]
				local value = subparts[2]
				data[key] = value
			end
			header = "local _DATA = "..textutils.serialize(data).."\n"
		end
		if msg:sub(1, url:len()) == url and (msg:sub(url:len()+1, url:len()+1) == "" or msg:sub(url:len()+1, url:len()+1) == "/") then
			local f = {string.gsub(msg, "[^/]+", "")}
			if f[2] > 1 then
				local str = ""
				for match in string.gmatch(msg, "[^/]+") do
					if match ~= url then
						str = str.."/"..match
					end
				end
				printLog("ID "..sender.." wants "..str)
				if fs.exists("/subsite"..str) then
					local file = fs.open("/subsite"..str, "r")
					rednet.send(sender, header..file.readAll())
					file.close()
				else
					if fs.exists("/404") then
						local file = fs.open("/404", "r")
						rednet.send(sender, header..file.readAll())
						file.close()
					else
						rednet.send(sender, "print(\"404 Not Found\")\nprint(\"This file does not exist on this site.\")")
					end
					printLog("Reply to ID "..sender..": 404")
				end
			else
				rednet.send(sender, header..site)
				printLog("ID "..sender.." wants main site")
			end
			printLog("Request by ID "..sender..": success.")
		end
	elseif event == "terminate" then
		printLog("Exiting.")
		sleep(0.1)
		os.pullEvent = oldPullEvent
		return
	end
end
]]

local file = fs.open("startup", "w")
file.write(code)
file.close()

print("rdnt-srv installed. Create the file 'site' if it doesn't exist.")