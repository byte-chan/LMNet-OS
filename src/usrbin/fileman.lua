local tArgs = { ... }
local fileMans = {}
local edit = 'edit' --or luaide ;D

fileMans[true] = function()
	local xLen,yLen = term.getSize()

	local color = {}
	color.dir = colors.yellow
	color.file = colors.white

	local workPath,saveFile,workCount,isDir,changePath,rmenu,popup,listFolder

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
		local waysActs = {
			['Open with Args'] = function() shell.run(pFile,popup('Args: ','input')) end,
			['Edit'] = function() shell.run(edit,pFile) end,
			['Upload to Pastebin'] = function() shell.run('pastebin','put',pFile) end,
			['Delete'] = function() if ui.yesno('Are you shure?','Delete '..pFile) then fs.delete(fs.combine(shell.dir(),pFile)) end end,
			['Rename'] = function() fs.move(pFile,popup("New File Name: ",'input')) end,
			['Copy'] = function() saveFile = '0'..fs.combine(shell.dir(),pFile) end,
			['Cut'] = function() saveFile = '1'..fs.combine(shell.dir(),pFile) end,
		}

		local ways = {'Open with Args','Edit','Upload to Pastebin','Delete','Rename','Copy','Cut'}

		if saveFile then
			waysActs['Paste'] = function() if saveFile:sub(1,1) == '0' then fs.copy(saveFile:sub(2,saveFile:len()),shell.dir()) end end
			table.insert(ways,'Paste')
		end

		term.clear()

		local lMessage = 'Upload to Pastebin'
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
				if mAct[evI[4]] then
					waysActs[mAct[evI[4]]]()
				end
				menu = false
			end
		end
	end

	function popup(pTxt,pMode)
		term.clear()

		local StartY = (yLen/2)-(3)
		for i=0,4 do
			paintutils.drawLine(1,StartY+i,xLen,StartY+i,colors.lightGray)
		end
		term.setCursorPos(1,StartY+1)
		term.setTextColor(colors.white)
		ui.cprint(pTxt)

		if pMode == 'input' then
			paintutils.drawLine(3,StartY+3,xLen-2,StartY+3,colors.white)
			term.setTextColor(colors.black)
			term.setCursorPos(3,StartY+3)
			return read()
		elseif pMode == 'msg' then
			sleep(3)
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
	if not ui then
		local success = os.loadAPI(".lmnet/apis/ui")
		if not success then
			local success2 = os.loadAPI("ui")
			if not success2 then
				printError("UI API not found")
				return
			end
		end
	end

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
				local selectedAction = ui.menu({"Go to", "Delete", "Move", "Copy", "New"}, "Actions for /"..shell.resolve(selected))
				if selectedAction then
					if selectedAction == "Go to" then
						shell.setDir(shell.resolve(selected))
						return true
					elseif selectedAction == "Delete" then
						fs.delete(shell.resolve(selected))
						return true
					end
				end
			else
				local selectedAction = ui.menu({"Run", "Edit", "Delete", "Move", "Copy", "New"}, "Actions for /"..shell.resolve(selected))
				if selectedAction then
					if selectedAction == "Run" then
						shell.run(selected)
						return true
					elseif selectedAction == "Edit" then
						shell.run(edit.." \""..selected.."\"")
						return true
					elseif selectedAction == "Delete" then
						fs.delete(shell.resolve(selected))
						return true
					end
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
