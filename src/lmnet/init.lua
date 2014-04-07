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
	for _, v in pairs(fs.list(dir)) do
		os.loadAPI(fs.combine(dir, v))
		table.insert(apiList, v)
	end
end
function bgSet(color)
	if color == colors.black or color == colors.white or term.isColor() then
		term.setBackgroundColor(color)
	end
end
function bgGet()
	return term.getBackgroundColor()
end
function fgSet(color)
	if color == colors.black or color == colors.white or term.isColor() then
		term.setTextColor(color)
	end
end
function fgGet()
	return term.getTextColor()
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
		print("Reinstall LMNet OS or run 'lmnet-updater' to fix this problem.")
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
updatePath(systemDirs.apps)

currentUser = "login"
hostName = "localhost"

if not fs.exists("/.lmnet/sys.conf") then
	write("Create system config? [Yn] ")
	local input = string.lower(read())
	if input ~= "y" and input ~= "" then
		clear()
		print("No config found.")
		print("Press any key to continue")
		while true do
			local e = os.pullEvent("key")
			if e == "key" then
				sleep(1)
				os.shutdown()
			end
			sleep(0)
		end
	end
	clear()
	write("Host name: ")
	local file = fs.open("/.lmnet/sys.conf", "w")
	file.writeLine("hostname=\""..read().."\"")
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

hostName = readConfig("hostname")
os.version = function()
	return "LMNet OS Beta"
end
clear()
shell.run("bash")