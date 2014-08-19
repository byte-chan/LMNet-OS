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
ui.cprint('GitHub Commits for @'..user..'/'..repo)
local col1,col2,tcol1,tcol2
local mode = 1

local function follow()
	local xP,yP = term.getCursorPos()
	local xL,yL = term.getSize()
	if yP+1 < yL then
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
	local startX,startY = term.getCursorPos()
	local oLines = {} 

	local mNfo = git.getSingleCommit(user,repo,input[i]['sha'])
	if #mNfo['files'] > 1 then
		for j=1,#mNfo['files'] do
			if j == 1 then
				oLines[1] = 'Edit: '..mNfo['files'][j]['filename']..','
			else
				table.insert(oLines,mNfo['files'][j]['filename']..',')	
			end
		end
	else
		oLines[1] = 'Edit: '..mNfo['files'][1]['filename']	
	end
	
	local usr = input[i]['commit']['author']['name']
	
	local otp = input[i]['commit']['message']
	otp = ui.splitStr(otp,xLen)
	
	table.insert(oLines,usr..': '..otp[1])
	for i=2,#otp do
		table.insert(oLines,otp[i])
	end

	if mode == 1 then
		term.setTextColor(tcol1)
		for k=startY,startY+#oLines do
			paintutils.drawLine(1,k,xLen,k,col1)
		end
		mode = 2
	else
		term.setTextColor(tcol2)
		for k=startY,startY+#oLines do
			paintutils.drawLine(1,k,xLen,k,col2)
		end
		mode = 1
	end

	term.setCursorPos(1,startY)
	for i=1,#oLines do
		local xP,yP = term.getCursorPos()
		write(oLines[i])
		term.setCursorPos(1,yP+1)
	end
	i = i+1
end

term.setCursorPos(1,yLen)
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clearLine()

write("Press any key to contine")
os.pullEvent('key')

term.clear()
term.setCursorPos(1,1)