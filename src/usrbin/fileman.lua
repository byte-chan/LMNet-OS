local tArgs = { ... }
local fileMans = {}
local edit = 'edit' --or luaide ;D

local popup,workPath,saveFile
local xLen,yLen = term.getSize()


if not ui then
	local whereCanBe = {'ui','.lmnet/apis/ui','apis/ui'}
	local loaded = false
	for i=1,#whereCanBe do
		if fs.exists(whereCanBe[i]) then
			os.loadAPI(whereCanBe[i])
			loaded = true
		end
	end
	if not loaded then
		printError("LMNet UI API is missing...")
		print("Start downloading as /ui...")
		local h = http.get('https://raw.github.com/MultHub/LMNet-OS/master/src/apis/ui.lua')
		if h then
			local f = fs.open("ui",'w')
			f.write(h.readAll())
			f.close()
			h.close()
			shell.run(shell.getRunningProgram())
			error(nil,0)
		else
			error("Can't get UI API! Is github on http whitelist?",0)
		end
	end
end

local function getFileMenu(isDir)
	local waysActs = {
		['Delete'] = function(pFile) if ui.yesno('Are you shure?','Delete '..pFile) then fs.delete(fs.combine(shell.dir(),pFile)) end end,
		['Rename'] = function(pFile) fs.move(pFile,popup("New File Name: ",'input')) end,
		['Copy'] = function(pFile) saveFile = '0'..fs.combine(shell.dir(),pFile) end,
		['Cut'] = function(pFile) saveFile = '1'..fs.combine(shell.dir(),pFile) end,
		['Back'] = function() end,
	}

	local ways = {}

	if isDir then
		waysActs['Open'] = function(pFile) shell.setDir(pFile) if term.isColor() then listFolder(pFile,1) end end
		ways[1] = 'Open'
	else
		waysActs['Run'] = function(pFile) shell.run(pFile) end
		ways[1] = 'Run'
		waysActs['Run with Args'] = function(pFile) shell.run(pFile,popup('Args: ','input')) end
		waysActs['Edit'] = function(pFile) shell.run(edit,pFile) end
		waysActs['Upload to Pastebin'] = function(pFile) shell.run('pastebin','put',pFile) end
	end

	if saveFile then
		waysActs['Paste'] = function() if saveFile:sub(1,1) == '0' then fs.copy(saveFile:sub(2,saveFile:len()),shell.dir()) end end
	end

	for i,v in pairs(waysActs) do
		if i ~= 'Open' or i ~= 'Run' or i ~= 'Back' then
			table.insert(ways,i)
		end
	end
	ways[#ways+1] = 'Back'

	return ways,waysActs
end

function popup(pTxt,pMode)
	term.clear()
	local bCol,tCol,tfCol
	if term.isColor() then
		bCol = colors.lightGray
		rtCol = colors.white
		tCol = colors.black
		tfCol = colors.white
	else
		bCol = colors.white
		rtCol = colors.black
		tCol = colors.white
		tfCol = colors.black
	end
	local StartY = (yLen/2)-(3)
	for i=0,4 do
		paintutils.drawLine(1,StartY+i,xLen,StartY+i,bCol)
	end
	term.setCursorPos(1,StartY+1)
	term.setTextColor(rtCol)
	ui.cprint(pTxt)

	if pMode == 'input' then
		paintutils.drawLine(3,StartY+3,xLen-2,StartY+3,tfCol)
		term.setTextColor(tCol)
		term.setCursorPos(3,StartY+3)
		return read()
	elseif pMode == 'msg' then
		sleep(3)
	end
end

fileMans[true] = function()

	local color = {}
	color.dir = colors.yellow
	color.file = colors.white

	local workCount,isDir,changePath,rmenu,listFolder

	function isDir(pWat)
		return fs.isDir(workPath..'/'..pWat)
	end

	function changePath()
		term.setTextColor(colors.black)
		paintutils.drawLine(1,1,xLen,1,colors.white)
		term.setCursorPos(1,1)
		write("/")
		local nPath = read()
		if not nPath then
			nPath = "/"
		end
		if fs.isDir(nPath) then
			listFolder(nPath,1)
		else
			popup("DIR DIDNT EXISTS!",'msg')
			listFolder(workPath,1)
		end
	end

	function rmenu(pFile)
		local ways,waysActs = getFileMenu(fs.isDir(pFile))
		term.clear()
		local lMessage = ''

		for i=1,#ways do
			if ways[i]:len() > lMessage:len() then
				lMessage = ways[i]
			end
		end

		lMessage = lMessage:len()

		local StartY = (yLen/2)-(#ways/2)
		local EndY = (yLen/2)+(#ways/2)

		local StartX = (xLen/2)-(lMessage/2)
		local EndX = (xLen/2)+(lMessage/2)

		local count = StartY-1
		local mAct = {}

		while count <= EndY+1 do
			paintutils.drawLine(StartX-1,count,EndX+1,count,colors.lightGray)
			count = count+1
		end

		term.setCursorPos(StartX,StartY)
		for i,v in ipairs(ways) do
			local xP,yP = term.getCursorPos()
			term.setTextColor(colors.black)
			ui.cprint(v)
			mAct[yP] = v
		end

		local menu = true
		while menu do
			local evI = { os.pullEvent() }
			if evI[1] == 'mouse_click' then
				if evI[3] >= StartX-1 and evI[3] <= EndX+1 then
					if mAct[evI[4]] then
						waysActs[mAct[evI[4]]]()
					end
				end
				menu = false
			end
		end
	end

	function listFolder(pFolder,pSite)
		if pFolder == '..' or pFolder == "/.." then
			pFolder = '/'
		end
		shell.setDir(pFolder)
		workPath = pFolder
		workCount = pSite
		term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1,1)
		paintutils.drawLine(1,1,xLen,1,colors.black)
		term.setTextColor(colors.white)
		term.setCursorPos(1,1)
		write("+")
		if pFolder:sub(1,1) == "/" then
			ui.cprint(pFolder)
		else
			ui.cprint('/'..pFolder)
		end
		term.setCursorPos(xLen-2,1)
		write("^ X")

		local flist = fs.list(pFolder)
		local count = 1
		local startAt = pSite
		local mde = true
		local col
		local dirs = {}
		local files = {}

		for _,v in ipairs(flist) do
			if fs.isDir(pFolder..'/'..v) then
				table.insert(dirs,v)
			else
				table.insert(files,v)
			end
		end

		flist = {}

		for _,v in ipairs(dirs) do
			table.insert(flist,v)
		end
		for _,v in ipairs(files) do
			table.insert(flist,v)
		end

		while count <= yLen-1 and #flist >= count do
			if mde then
				col = colors.gray
			else
				col = colors.lightGray
			end
			paintutils.drawLine(1,count+1,xLen,count+1,col)
			term.setCursorPos(3,count+1)
			term.setTextColor(colors.white)
			write(flist[(startAt-1)+count])
			term.setTextColor(colors.black)
			if fs.isDir(pFolder..'/'..flist[(startAt-1)+count]) then
				paintutils.drawPixel(1,count+1,color.dir)
				term.setCursorPos(1,count+1)
				write("D")
			else
				paintutils.drawPixel(1,count+1,color.file)
				term.setCursorPos(1,count+1)
				write("F")
			end
			count = count+1
		end

		while true do
			local ev = { os.pullEvent() }
			if ev[1] == "mouse_click" then
				if ev[4] == 1 then
					if ev[3] == 1 then
						local o = popup("Make new File: ",'input')
						if o and o ~= '' then
							local f = fs.open(o,'w')
							f.close()
						end
					elseif ev[3] == xLen-2 then
						if pFolder ~= '/' or pFolder ~= '' then
							local x = shell.resolve('..')
							listFolder(x,1)
						end
					elseif ev[3] == xLen then
						term.clear()
						term.setCursorPos(1,1)
						error()
					else
						changePath()
					end
				else
					local _FILE = (startAt-1)+(ev[4]-1)
					if flist[_FILE] then
						if ev[2] == 1 then
							if isDir(flist[_FILE]) then
								listFolder(pFolder..'/'..flist[_FILE],1)
							else
								shell.run(flist[_FILE])
								listFolder(pFolder,pSite)
							end
						elseif ev[2] == 2 then
							rmenu(flist[_FILE])
							listFolder(pFolder,pSite)
						end
					end
				end
			elseif ev[1] == "mouse_scroll" then
				if ev[2] == 1 then
					if #flist-(pSite-1) > yLen then
						listFolder(pFolder,pSite+1)
					end
				elseif ev[2] == -1 then
					if pSite > 1 then
						listFolder(pFolder,pSite-1)
					end
				end
			elseif ev[1] == 'key' then
				if ev[2] == keys.down then
					if #flist-(pSite-1) > yLen then
						listFolder(pFolder,pSite+1)
					end
				elseif ev[2] == keys.up then
					if pSite > 1 then
						listFolder(pFolder,pSite-1)
					end
				end
			end
		end 
	end

	local openAtStart

	if tArgs[1] then
		openAtStart = tArgs[1]
	else
		openAtStart = shell.dir()
	end

	listFolder(openAtStart,1)
end

fileMans[false] = function()
	
	local function itemList()
		local items = fs.list(shell.dir())
		table.sort(items)
		if shell.dir() ~= "" then
			table.insert(items, 1, "..")
		end
		return items
	end

	local function files()
		local selected = ui.menu(itemList(), "/"..shell.dir())
		if selected then
			if fs.isDir(shell.resolve(selected)) then
				local ways,waysActs = getFileMenu(true)
				local selectedAction = ui.menu(ways, "Actions for /"..shell.resolve(selected))
				if selectedAction then
					waysActs[selectedAction](shell.resolve(selected))
					return true
				end
			else
				local ways,waysActs = getFileMenu(false)
				local selectedAction = ui.menu(ways, "Actions for /"..shell.resolve(selected))
				if selectedAction then
					waysActs[selectedAction](shell.resolve(selected))
					return true
				end
			end
		end
		return false
	end

	local running = true
	while running do
		local selection = files()
		if not selection then
			running = false
		end
		sleep(0)
	end
end

fileMans[term.isColor()]()
