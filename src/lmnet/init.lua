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
	write("Host name: ")
	local file = fs.open("/.lmnet/sys.conf", "w")
	file.writeLine("hostname=\""..read().."\"")
	file.writeLine("debug=false")
	file.writeLine("showCalc=true")
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

if config.read("debug") then
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
if config.read("showCalc") and term.isColor() then
	shell.openTab("/usr/bin/calc")
end
os.version = function()
	return "LMNet OS 1.1"
end
shell.run(".lmnet/login")
clear()
fgSet(colors.yellow)
print(os.version())
fgSet(colors.white)
shell.run("/usr/bin/bash", "--init")
shell.run("/rom/programs/shutdown")