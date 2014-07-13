if not fs or not term or not shell then
	print("No CraftOS APIs found (not running on CraftOS).")
	if os.getenv("OS") == "Windows_NT" then
		print("You are a proud Windows user.")
	end
	return
end

-- load system API
function clear()
	term.clear()
	term.setCursorPos(1, 1)
end
function getSize()
	local x, y = term.getSize()
	local ret = {
		["x"] = x, ["y"] = y
	}
	return ret
end
function setCursor(x, y)
	term.setCursorPos(x, y)
end
function getCursor()
	local x, y = term.getCursorPos()
	local ret = {
		["x"] = x, ["y"] = y
	}
	return ret
end
function setBlink(val)
	term.setCursorBlink(val)
end
function updatePath(dir, prepend)
	if prepend then
		shell.setPath(dir..":"..shell.path())
	else
		shell.setPath(shell.path()..":"..dir)
	end
end
function loadAPIs(dir)
	if not fs.isDir(dir) then
		return
	end
	for _, v in pairs(fs.list(dir)) do
		if not fs.isDir(fs.combine(dir, v)) then
			os.loadAPI(fs.combine(dir, v))
			table.insert(apiList, v)
		end
	end
end
function bgSet(color)
	if color == colors.black or color == colors.white or term.isColor() then
		term.setBackgroundColor(color)
	end
end
function fgSet(color)
	if color == colors.black or color == colors.white or term.isColor() then
		term.setTextColor(color)
	end
end
function readConfig(cfg)
	local file = fs.open("/.lmnet/sys.conf", "r")
	if not file then
		return nil
	end
	local lines = {}
	local line = ""
	while line ~= nil do
		line = file.readLine()
		if line then
			table.insert(lines, line)
		end
	end
	file.close()
	local config = {}
	for _, v in pairs(lines) do
		local tmp
		local tmp2 = ""
		for match in string.gmatch(v, "[^\=]+") do
			if tmp then
				tmp2 = tmp2..match
			else
				tmp = match
			end
		end
		config[tmp] = textutils.unserialize(tostring(tmp2))
	end
	for i, v in pairs(config) do
		if i == cfg then
			return v
		end
	end
	return nil
end
function loadAPI(filename, loadas)
	if not fs.exists(filename) then
		return false
	end
	if not loadas then
		loadas = fs.getName(filename)
	end
	local fenv = {}
	setmetatable(fenv, {__index = _G})
	local func, err = loadfile(filename)
	if func then
		setfenv(func, fenv)
		func()
	else
		return false, err
	end
	local api = {}
	for i, v in pairs(fenv) do
		api[i] =  v
	end
	_G[loadas] = api
end

apiList = {}

-- initialize system directories (and create missing)
systemDirs = {
	users = "/home", -- users directory
	root = "/root", -- root directory (root USER)
	apps = "/usr/bin", -- applications directory
	apis = "/.lmnet/apis", -- API directory
}

for _, v in pairs(systemDirs) do
	if not fs.exists(v) then
		clear()
		fgSet(colors.red)
		print("Missing directories!")
		print("Reinstall LMNet OS or run 'updater' to fix this problem.")
		fgSet(colors.white)
		return
	end
end
	
for _, v in pairs(systemDirs) do
	if not fs.exists(v) then
		fs.create(v)
	end
end

-- load APIs
print("Loading APIs...")
loadAPIs(systemDirs.apis)
if turtle then
	print("Loading turtle APIs...")
	loadAPIs(fs.combine(systemDirs.apis, "turtle"))
end
if http then
	print("Loading http APIs...")
	loadAPIs(fs.combine(systemDirs.apis, "http"))
end

-- add applications directory to path
updatePath(systemDirs.apps, true)

currentUser = "login"
hostName = "localhost"

if not fs.exists("/.lmnet/sys.conf") then
	print("Create system config?")
	write("[Yn] ")
	local input = string.lower(read())
	if input ~= "y" and input ~= "" then
		clear()
		print("No config found.")
		print("Press any key to continue")
		os.pullEvent("key")
		sleep(1)
		os.shutdown()
	end
	clear()
	local preName = os.getComputerLabel()
	local setName
	if preName then
		print("Host name: "..preName)
		print("Press E to edit,")
		print("enter to continue")
		local ev = {os.pullEventRaw()}
		if ev[1] == 'key' then
			if ev[2] == keys.e then
				term.setCursorPos(1, 2)
				term.clearLine()
				print("Up x1 for label,")
				term.clearLine()
				print("up x2 for id"..os.getComputerID()..".")
				term.setCursorPos(12, 1)
				setName = read(nil, {"id"..os.getComputerID(), preName})
			elseif ev[2] == keys.enter then
				setName = preName	
			end
		elseif ev[1] == 'terminate' then
			setName = preName 
		end
	else
		write("Host name: ")
		setName = read()
	end
	os.setComputerLabel(setName)
	local file = fs.open("/.lmnet/sys.conf", "w")
	file.writeLine("hostname=\""..setName.."\"")
	file.writeLine("debug=false")
	print("Open calc tab on startup?")
	write("[Yn]")
	local input = read():lower()
	local calc
	if input == 'y' or input == '' then
		calc = true	
	else
		calc = false
	end
	file.writeLine("showCalc="..tostring(calc))
	file.close()
	print("Press any key to continue")
	while true do
		local e = os.pullEvent("key")
		if e == "key" then
			sleep(1)
			os.reboot()
		end
		sleep(0)
	end
end

if config.read(nil, "debug") then
	local timer = os.startTimer(0.5)
	while true do
		local e, k = os.pullEvent()
		if e == "timer" and k == timer then
			break
		elseif e == "key" and k == keys.leftCtrl then
			lmnet_debug = true
			break
		end
	end
end

if lmnet_debug then
	clear()
	print("LMNet OS debug mode")
	shell.setDir(".lmnet")
	shell.setPath(".:/rom/programs")
	return
end

hostName = readConfig("hostname")
if config.read(nil, "showCalc") and term.isColor() then
	shell.openTab("/usr/bin/calc")
elseif config.read("/.lmnet/tim.conf", "upd8") then
	shell.run("/usr/bin/changelog")
	local x = config.list()
	x['upd8'] = nil
	for i,v in pairs(x) do
		config.write("/.lmnet/tim.conf",i,v)
	end
end
os.version = function()
	return config.read(nil, "oem") or "LMNet OS 1.1"
end
shell.setDir("")
if fs.exists("/.lmnet/oemboot") then
	shell.run("/.lmnet/oemboot")
end
shell.run("/.lmnet/login")
if fs.exists("/.lmnet/oemstart") then
	shell.run("/.lmnet/oemstart")	
end
if not config.read(nil, "classicLogin") then
	clear()
end
fgSet(colors.yellow)
print(os.version())
fgSet(colors.white)
shell.run("/usr/bin/bash", "--init")
shell.run("/rom/programs/shutdown")
