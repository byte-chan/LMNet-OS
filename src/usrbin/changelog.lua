local tArgs = { ... }

local user,repo
if #tArgs == 2 then
	user = tArgs[1]
	repo = tArgs[2]
else
	user = 'MultHub'
	repo = 'LMNet-OS'
end

local input = git.getCommits(user,repo)
local xLen,yLen = term.getSize()
term.clear()
term.setCursorPos(1,1)
ui.cprint('GitHub Commits for '..repo)
local col1,col2,tcol1,tcol2
local mode = 1

local editorColors = {}
editorColors.Multi = colors.yellow
editorColors["Tim Ittermann"] = colors.blue

local function follow()
	local xP,yP = term.getCursorPos()
	local xL,yL = term.getSize()
	if yP < yL then
		return true
	else
		return false
	end
end

if term.isColor() then
	col1 = colors.gray
	col2 = colors.lightGray
	tcol1 = colors.white
	tcol2 = colors.black
else
	col1 = colors.white
	col2 = colors.black
	tcol1 = colors.black
	tcol2 = colors.white
end

local i = 1
while follow() do
	local usr = input[i]['commit']['author']['name']
	if editorColors[usr] and term.isColor() then
		term.setTextColor(editorColors[usr])
	end
	write(usr)
	if mode == 1 then
		term.setTextColor(tcol1)
		term.setBackgroundColor(col1)
		mode = 2
	else
		term.setTextColor(tcol2)
		term.setBackgroundColor(col2)
		mode = 1
	end
	print(':',input[i]['commit']['message'])
	i = i+1
end
term.setCursorPos(1,yLen)
term.clearLine()
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
write("Press any key to contine")
os.pullEvent('key')
term.clear()
term.setCursorPos(1,1)
