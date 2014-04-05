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
function getCursor(val)
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
		print("Reinstall LMNet OS or run '.lmnet/update' to fix this problem.")
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
loadAPIs(systemDirs.apis)
if turtle then
	loadAPIs(fs.combine(systemDirs.apis, "turtle"))
end
if http then
	loadAPIs(fs.combine(systemDirs.apis, "http"))
end

-- add applications directory to path
updatePath(systemDirs.apps)

shell.run("bash")