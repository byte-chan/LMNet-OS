if not term then
	print("Not running in CraftOS.")
	return
end

local parentShell = shell

local bExit = false
local sDir = (parentShell and parentShell.dir()) or ""
local sPath = (parentShell and parentShell.path()) or ".:/rom/programs"
local tAliases = (parentShell and parentShell.aliases()) or {}

local promptColor, textColor, bgColor
if term.isColor() then
	promptColor = colors.yellow
	textColor = colors.white
	bgColor = colors.black
else
	promptColor = colors.white
	textColor = colors.white
	bgColor = colors.black
end

local bashconfig = config.list("/.lmnet/bash.conf")
if bashconfig then
	if bashconfig.prompt and (term.isColor() or colors[bashconfig.prompt] == colors.black or colors[bashconfig.prompt] == colors.white) then
		promptColor = colors[bashconfig.prompt]
	end
	if bashconfig.text and (term.isColor() or colors[bashconfig.prompt] == colors.black or colors[bashconfig.prompt] == colors.white) then
		textColor = colors[bashconfig.text]
	end
	if bashconfig.bg and (term.isColor() or colors[bashconfig.prompt] == colors.black or colors[bashconfig.prompt] == colors.white) then
		bgColor = colors[bashconfig.bg]
	end
end

shell.exit = function()
	bExit = true
end

local tArgs = {...}
if #tArgs > 0 then
	for i = 1, #tArgs do
		if tArgs[i] == "--init" then
			if currentUser == "root" then
				shell.setDir(shell.resolve(systemDirs.root))
			else
				shell.setDir(shell.resolve(fs.combine(systemDirs.users, currentUser)))
				if not fs.exists(shell.dir()) then
					fs.makeDir(shell.dir())
				end
			end
		end
	end
end

local tCommandHistory = {}
while not bExit do
	term.setBackgroundColor(bgColor)
	term.setTextColor(promptColor)
	function iif(cond, trueval, falseval)
		if cond then
			return trueval
		else
			return falseval
		end
	end
	local userPath = iif(currentUser == "root", systemDirs.root, fs.combine(systemDirs.users, currentUser))
	local dir = iif(
		shell.dir() == userPath or (
			shell.dir():sub(1, userPath:len()) == userPath and (
				shell.dir():len() == userPath:len() or (
					shell.dir():len() > userPath:len() and shell.dir():sub(userPath:len()+1, userPath:len()+1) == "/"
				)
			)
		),
		"~"..shell.dir():sub(userPath:len()+1),
		"/"..shell.dir()
	)
	term.clearLine()
	local w, h = term.getSize()
	if w < 30 and h < 25 then
		write(
		dir .. iif(currentUser == "root",
			"#",
			"$"
		) .. " "
		)
	else
		write(
		"[" .. currentUser .. "@" .. hostName .. " " .. dir .. "]" .. iif(currentUser == "root",
			"#",
			"$"
		) .. " "
		)
	end
	term.setTextColor(textColor)
	local sLine = read(nil, tCommandHistory)
	table.insert(tCommandHistory, sLine)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
	shell.run(sLine)
end