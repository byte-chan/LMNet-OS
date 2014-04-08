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
	local dir = iif(shell.dir() == fs.combine(
		systemDirs.users, currentUser
	) or (shell.dir() == systemDirs.root and currentUser == "root"),
		"~",
		"/"..shell.dir()
	)
	local w, h = term.getSize()
	if w < h then
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
	shell.run(sLine)
end