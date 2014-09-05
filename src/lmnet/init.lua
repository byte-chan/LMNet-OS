if not fs or not term or not shell then
	print("No CraftOS APIs found (not running on CraftOS).")
	if os.getenv("OS") == "Windows_NT" then
		print("You are a proud Windows user.")
	end
	return
end

local function splitStr(str, maxWidth) -- WASP FTW
	local rawwords = {}
	for word in str:gmatch("[^ \t]+") do
		table.insert(rawwords, word)
	end
	local words = {}
	for i, word in ipairs(rawwords) do
		local matches = {}
		for match in word:gmatch("[^\n]+") do
			table.insert(matches, match)
		end
		for i, v in pairs(matches) do
			table.insert(words, (i > 1 and "\n" or "")..v)
		end
	end -- testing shit
	local lines = {}
	local cLn = 1
	for i, word in ipairs(words) do
		if not lines[cLn] then
			lines[cLn] = word
		elseif (lines[cLn].." "..word):len() > maxWidth or word:sub(1, 1) == "\n" then
			cLn = cLn + 1
			lines[cLn] = word:sub(1, 1) == "\n" and word:sub(2) or word
		else
			lines[cLn] = lines[cLn].." "..word
		end
	end
	return lines
end

-- load system API
function bsodError(msg)
	local oldTerm = term.current()
	term.redirect(term.native())
	term.setBackgroundColor(colors.black)
	if term.isColor() then
		term.setBackgroundColor(colors.blue)
	end
	term.setTextColor(colors.white)
	term.clear()
	local termValues = {}
	setmetatable(termValues, {__index = function(self, k)
		local x, y = term.getCursorPos()
		local w, h = term.getSize()
		local cx, cy = math.ceil(w/2), math.ceil(h/2)
		local rtn = {x=x,y=y,w=w,h=h,cx=cx,cy=cy}
		return rtn[k]
	end})
	local function cprint(text, ln)
		term.setCursorPos(termValues.cx-math.floor(text:len()/2), ln)
		print(text)
	end
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.black)
	if term.isColor() then
		term.setTextColor(colors.blue)
	end
	cprint(" LMNet OS ", 3)
	term.setBackgroundColor(colors.black)
	if term.isColor() then
		term.setBackgroundColor(colors.blue)
	end
	term.setTextColor(colors.white)
	local win = window.create(term.current(), 3, 5, termValues.w - 2, termValues.h - 4, true)
	win.setTextColor(colors.white)
	win.setBackgroundColor(term.isColor() and colors.blue or colors.black)
	win.clear()
	win.setCursorPos(1, 1)
	local parentTerm = term.current()
	term.redirect(win)
	local winwidth, winheight = win.getSize()
	for i, v in ipairs(splitStr(msg, winwidth)--[[HEADDESKHEADDESKHEADDESKHEADDESKHEADDESKHEADDESKHEADDESKHEADDESK]]) do
		local wincursorx, wincursory = win.getCursorPos()
		print(v)
		if wincursory == winheight then
			os.pullEvent("key")
		end
	end
	term.redirect(parentTerm)
	cprint("Press any key to continue", termValues.h - 2)
	os.pullEvent("key")
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	term.clear()
	term.setCursorPos(1, 1)
	term.redirect(oldTerm)
end
local bgmgr = {}
setmetatable(bgmgr, {__index = getfenv()})
local filefunc, err = loadfile(".lmnet/apis/comgr")
if not filefunc then
	printError("No coroutine manager API found, try updating LMNet OS.")
	if err then
		printError("Error:")
		printError(err)
		printError("Report this error if possible.")
		printError("(new issue)")
	end
	print("System boot mode: no background programs")
	print("Press any key to boot.")
	os.pullEvent("key")
end
if filefunc then
	setfenv(filefunc, bgmgr)()
	bgManager = {}
	function bgManager.addFunction(func)
		return bgmgr.addProcess(func)
	end
	function bgManager.removeFunction(id)
		bgmgr.removeProcess(id)
	end
end
function main()
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

function localize(key)
	if not config.read(nil, "lang") then
		config.write(nil, "lang", "en")
	end
	return config.read(".lmnet/lang/"..config.read(nil, "lang")..".lang", key) or config.read(".lmnet/lang/en.lang", key) or key
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
	x['upd8'] = false
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
shell.setAlias('fs','/usr/bin/fileman')
shell.setAlias('ls+','/usr/bin/fileman')
shell.run("/usr/bin/bash", "--init")
end
local function handleCrash(err)
	if err then
		bsodError("System crash:\n\n"..err)
	else
		bsodError("System crash:\n\n<unknown source>")
	end
end
local function _main()
	local _ok, _err = pcall(main)
	if not _ok then
		handleCrash(_err)
	end
	if filefunc then
		bgmgr.forceExit()
	end
end
if filefunc then
	bgmgr.addProcess(_main)
	bgmgr.addProcess(function()
		local errorLevels = {
			"INFO",
			"WARNING",
			"ERROR",
			"CRITICAL",
			"SEVERE",
			"FATAL",
			[1337] = "OH SHIT OH SHIT OH SHIT OHSHITOHSHIT!!!!!!!!!!!!!!!!!!!!!!!!11!!!!!!!!!!1111!11!1!!11!!1!11111!!1",
			[9001] = "IT'S OVER 9000!!!",
			[4294967296] = "42949697296",
			[(10^(-20))] = "OH SHIT THAT'S AN ERROR!!!",
			[2109] = "timia2109 :)",
			[0] = "NIL :D",
			[-9001] = "IT'S UNDER -9000!!!",
			[1234567890] = "WHO THE FUCK ADDED THIS ERROR LEVEL",
		}
		while true do
			local e, msg, errorLevel = os.pullEventRaw("syslog")
			if e == "syslog" and msg then
				local logfile = fs.open(".lmnet/sys.log", "a")
				local day = tostring(os.day())
				local dayFormat = string.rep(" ", 5-day:len())..day
				local time = tostring(textutils.formatTime(os.time(), true))
				local timeFormat = string.rep(" ", 5-time:len())..time
				local errLevel = type(errorLevel) == "number" and errorLevel or 0
				local str = "["..dayFormat.." "..timeFormat.."] ["..(errorLevels[errLevel] or "unknown").."] "
				logfile.writeLine(str..msg)
				logfile.close()
				write(str)
				if errLevel > 2 and errLevel < 7 then
					printError(msg)
				else
					print(msg)
				end
			end
		end
	end)
	bgmgr.run()
else
	local _ok, _err = pcall(_main)
	if not _ok then
		handleCrash(_err)
	end
	if bgmgr then
		bgmgr.forceExit()
	end
end
shell.run("/rom/programs/shutdown")
