local input = git.getCommits('MultHub','LMNet-OS')
local xLen,yLen = term.getSize()
term.clear()
term.setCursorPos(1,1)
ui.cprint('LMNet-OS Changelog (GitHub Commits)')
local col1,col2,tcol1,tcol2
local mode = 1

if term.isColor() then
	col1 = colors.gray
	col2 = colors.lightGray
	tcol1 = colors.white
	tcol2 = colors.black
	multi = colors.yellow
	timia2109 = colors.blue
else
	col1 = colors.white
	col2 = colors.black
	tcol1 = colors.black
	tcol2 = colors.white
end

for i=1,5 do
	local usr = input[i]['commit']['author']['name']
	if usr == 'Tim Ittermann' or usr == 'timia2109' then
		if timia2109 then
			term.setTextColor(timia2109)
		end
	elseif usr == 'Multi' then
		if multi then
			term.setTextColor(multi)
		end
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
end
term.setCursorPos(1,yLen)
term.clearLine()
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
write("Press any key to contine")
os.pullEvent('key')
term.clear()
term.setCursorPos(1,1)