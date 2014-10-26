function version() 
	return 1,"LMNetUI"
end

function has(pWhat)
	-- I want a boolean, not a function...
	return ui[pWhat] ~= nil 
end

function colorPicker(title, moreText, customColors)
	local screenTitle = title or "Color Picker"
	local colorList = {}
	local selected = 1
	if customColors then
		for i = 1, #customColors do
			table.insert(colorList, customColors[i])
		end
	else
		for i = 0, 15 do
			local num = 2^i
			if term.isColor() or num == 1 or num == 32768 then
				table.insert(colorList, num)
			end
		end
	end
	local function redraw()
		term.setTextColor(1)
		term.setBackgroundColor(32768)
		term.clear()
		term.setCursorPos(1, 1)
		local w, h = term.getSize()
		local cx, cy = math.ceil(w/2), math.ceil(h/2)
		term.setCursorPos(cx-math.floor(screenTitle:len()/2), 1)
		print(screenTitle)
		if moreText then
			for i, v in pairs(moreText) do
				print(v)
			end
		end
		for i = 1, #colorList do
			term.setTextColor(colorList[i])
			if selected == i then
				write("#")
			else
				write("_")
			end
		end
		term.setCursorPos(1, h-1)
		term.setTextColor(colors.white)
		term.setBackgroundColor(colors.black)
		write("Use arrow keys to move,")
		term.setCursorPos(1, h)
		write("press enter to pick color.")
	end
	local oldPullEvent = os.pullEvent
	os.pullEvent = os.pullEventRaw
	while true do
		redraw()
		local event = {os.pullEvent()}
		if event[1] == "terminate" then
			os.pullEvent = oldPullEvent
			return
		elseif event[1] == "key" then
			if event[2] == keys.left then
				if selected == 1 then
					selected = #colorList
				else
					selected = selected - 1
				end
			elseif event[2] == keys.right then
				if selected == #colorList then
					selected = 1
				else
					selected = selected + 1
				end
			elseif event[2] == keys.enter then
				os.pullEvent = oldPullEvent
				return colorList[selected]
			end
		end
	end
end

function cprint(text)
	if type(text) ~= 'table' then
		text = {text}
	end
	
	local w, h = term.getSize()
	
	for i=1,#text do
		local x, y = term.getCursorPos()
		term.setCursorPos(math.floor(w/2)-math.floor(text[i]:len()/2), y)
		print(text[i])
	end
end

function menu(items, title, start,allowNil,moreTitle)
	local function clear()
		term.clear()
		term.setCursorPos(1, 1)
	end
	
	local termWidth, termHeight = term.getSize()
	local drawSize = termHeight - 6
	
	local function maxPages()
		local itemCount = #items
		local pageCount = 0
		while itemCount > 0 do
			itemCount = itemCount - drawSize
			pageCount = pageCount + 1
		end
		return pageCount
	end
	
	local function iif(cond, trueval, falseval)
		if cond then
			return trueval
		else
			return falseval
		end
	end
	
	local function pagedItems()
		local ret = {}
		for i = 1, maxPages() do
			local tmp = {}
			local nElements = 0
			for j = drawSize*(i-1)+1, iif(drawSize*(i+1) > #items, #items, drawSize*(i+1)) do
				if nElements < drawSize then
					table.insert(tmp, items[j])
					nElements = nElements + 1
				end
			end
			table.insert(ret, tmp)
		end
		return ret
	end
	
	local selected = 1
	if start then
		selected = start
	end
	local page = 1
	
	local function redraw()
		term.setBackgroundColor(colors.black)
		clear()
		cprint(title)
		if moreTitle then
			head = moreTitle
		else
			head = {"Select with arrow keys or with mouse.","Press enter to select.",}
			if not allowNil or allowNil == true then
				head[3] = 'Terminate to cancel.'
			end
		end
		for i=1,3 do
			print(head[i])
		end
		pages = "<- (page "..page.." of "..maxPages()..") ->"
		print(pages)
		for i = 1, #pagedItems()[page] do
			if selected == drawSize*(page-1)+i then
				term.setBackgroundColor(colors.white)
				term.setTextColor(colors.black)
			else
				term.setBackgroundColor(colors.black)
				term.setTextColor(colors.white)
			end
			term.clearLine()
			print(iif(selected == drawSize*(page-1)+i, ">", " ").." "..pagedItems()[page][i])
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.white)
		end
	end

	local function changePage(pW)
		if pW == 1 and page < maxPages() then
			page = page + 1
			if selected + drawSize > #items then
				selected = #items
			else
				selected = selected + drawSize
			end
		elseif pW == -1 and page > 1 then
			page = page - 1
			if selected - drawSize < 1 then
				selected = 1
			else
				selected = selected - drawSize
			end
		end
	end
	
	while true do
		redraw()
		local eventData = {os.pullEventRaw()}
		if eventData[1] == "terminate" then
			if not allowNil or allowNil == true then
				clear()
				return nil
			end
		elseif eventData[1] == "key" then
			if eventData[2] == keys.up and selected > 1 then
				selected = selected - 1
				if selected-(page-1)*drawSize < 1 then
					page = page - 1
				end
			elseif eventData[2] == keys.down and selected < #items then
				selected = selected + 1
				if selected-(page-1)*drawSize > drawSize then
					page = page + 1
				end
			elseif eventData[2] == keys.enter then
				clear()
				return items[selected]
			elseif eventData[2] == keys.left then
				changePage(-1)
			elseif eventData[2] == keys.right then
				changePage(1)
			end
		elseif eventData[1] == 'mouse_click' then
			if eventData[4] > 5 then
				clear()
				selected = (eventData[4]-6+((page-1)*drawSize))+1
				return items[selected]
			elseif eventData[4] == 5 then
				if eventData[3] == 1 or eventData[3] == 2 then
					changePage(-1)
				elseif eventData[3] == pages:len()-1 or eventData[3] == pages:len()-2 then
					changePage(1)
				end
			end
		elseif eventData[1] == 'mouse_scroll' then
			if eventData[2] == 1 then
				changePage(1)
			elseif eventData[2] == -1 then
				changePage(-1)
			end
		end
		sleep(0)
	end
end

function yesno(text, title, start)
	local function clear()
		term.clear()
		term.setCursorPos(1, 1)
	end
	
	local function drawButton(buttonText, x, y, x2, y2, enabled)
		if enabled then
			term.setBackgroundColor(colors.white)
		else
			if term.isColor() then
				term.setBackgroundColor(colors.gray)
			end
		end
		term.setCursorPos(x, y)
		for _y = y, y2 do
			for _x = x, x2 do
				term.setCursorPos(_x, _y)
				write(" ")
			end
		end
		term.setCursorPos(x+math.floor((x2-x)/2)-math.floor(buttonText:len()/2), y+math.floor((y2-y+1)/2))
		term.setTextColor(colors.black)
		write(buttonText)
		term.setTextColor(colors.white)
		term.setBackgroundColor(colors.black)
	end
	
	local selected = true
	
	local function redraw()
		clear()
		cprint(title)
		term.setCursorPos(1, 3)
		print(text)
		local w, h = term.getSize()
		drawButton("Yes", 2, h-1, math.floor(w/2)-1, h-1, selected)
		drawButton("No", math.floor(w/2)+1, h-1, w-1, h-1, not selected)
	end
	
	if start ~= nil and type(start) == "boolean" then
		selected = start
	end
	local w, h = term.getSize()
	while true do
		redraw()
		local eventData = {os.pullEventRaw()}
		if eventData[1] == "terminate" then
			clear()
			return
		elseif eventData[1] == "key" then
			if eventData[2] == keys.up or eventData[2] == keys.down or eventData[2] == keys.left or eventData[2] == keys.right then
				selected = not selected
			elseif eventData[2] == keys.enter then
				clear()
				return selected
			end
		elseif eventData[1] == 'mouse_click' then
			if eventData[4] == h-1 then
				if eventData[3] >= math.floor(w/2)+1 and eventData[3] <= w-1 then
					clear()
					return false
				elseif eventData[3] >= 2 and eventData[3] <= math.floor(w/2)-1 then
					clear()
					return true
				end
			end
		end
		sleep(0)
	end
end

function button(pLabel,pX,pY,pCol)
	local xLen,yLen = term.getSize()
	local rtn = {}
	local rtn_m = {}
	rtn_m.__index = rtn_m
	rtn.label = pLabel
	if pX == 'm' then
		rtn.xStart = (xLen/2)-(pLabel:len()/2)
	else
		rtn.xStart = pX
	end

	rtn.xEnd = rtn.xStart+pLabel:len()+2
	rtn.y = pY
	rtn.color = pCol
	rtn.textColor = colors.white
	rtn.onClick = nil
	rtn.autoExec = true
	rtn.type = "button"
	
	setmetatable(rtn,rtn_m)

	function rtn_m:draw()
		paintutils.drawLine(self.xStart,self.y,self.xEnd,self.y,self.color)
		term.setCursorPos(self.xStart+1,self.y)
		term.setTextColor(self.textColor)
		write(self.label)
	end

	function rtn_m:setNewLabel(pLabel)
		local oLabel = self.label
		self.label = pLabel
		self.xEnd = self.xStart+self.label:len()+2 
	end
	
	function rtn_m:isClicked(pX,pY)
		if pY == self.y and pX >= self.xStart and pX <= self.xEnd then
			if self.autoExec and self.onClick then
				self.onClick()
			end
			return true
		else
			return false
		end 
	end
	
	return rtn
end

function clickedElements(pX,pY, ... )
	local x = { ... }
	for i,v in pairs(x) do
		if v:isClicked(pX,pY) then
			if v.type == 'button' then
				v:exec()
			end
			return v.label
		end
	end
	return false
end

clickedButtons = clickedElements

function progressBar(pX,pY,pLen,pCol,pTxt)
	local rtn = {}
	local rtn_m = {}
	rtn_m.__index = rtn_m

	rtn.x = pX
	rtn.y = pY
	rtn.len = pLen
	rtn.color = pCol
	rtn.textColor = colors.white
	rtn.showText = pTxt
	rtn.percent = 0
	rtn.type = "progressBar"

	setmetatable(rtn,rtn_m)

	function rtn_m:draw()
		term.setCursorPos(self.x,self.y)
		term.clearLine()
		local leng = math.floor((self.percent/100)*self.len)
		paintutils.drawLine(self.x,self.y,leng,self.y,self.color)
		term.setTextColor(self.textColor)
		term.setCursorPos((self.len/2)-1,self.y)
		term.setBackgroundColor(colors.black)
		write(tostring(self.percent)..' %')
	end

	return rtn
end

function splitStr(str, maxWidth)
	local words = {}
	for word in str:gmatch("[^ \t]+") do
		table.insert(words, word)
	end
	local lines = {}
	local cLn = 1
	for i, word in ipairs(words) do
		if not lines[cLn] then
			lines[cLn] = word
		elseif (lines[cLn].." "..word):len() > maxWidth then
			cLn = cLn + 1
			lines[cLn] = word
		else
			lines[cLn] = lines[cLn].." "..word
		end
	end
	return lines
end

function textField(pId,pX,pY,pLen,pBg,pTxt)
	local rtn = {}
	local rtn_m = {}
	rtn_m.__index = rtn_m
	rtn.x = pX
	rtn.y = pY
	
	if pLen == 'f' then
		local b
		rtn.len,b = term.getSize()
	else
		rtn.len = pLen
	end
	
	rtn.textColor = pTxt
	rtn.backgroundColor = pBg
	rtn.onClickRead = true
	rtn.value = ''
	rtn.id = pId
	rtn.text = pId
	rtn.type = "textField"
	
	setmetatable(rtn,rtn_m)
	
	function rtn_m:draw()
		paintutils.drawLine(self.x,self.y,self.len,self.y,self.backgroundColor)
		local sign,gray
		if self.value ~= '' then
			sign = self.value
			gray = false
		else
			sign = self.text
			gray = true
		end
		
		term.setCursorPos(self.x,self.y)
		term.clearLine()
		if gray then
			term.setTextColor(colors.gray)
		else
			term.setTextColor(self.textColor)
		end
		
		local i = 1
		while i <= sign:len() and i <= self.len do
			write(sign:sub(i,i))
			i = i+1
		end
	end
	
	function rtn_m:isClicked(pX,pY)
		if pX >= self.x and pX <= self.len and pY == self.y then
			if self.onClickRead then
				term.setCursorPos(self.x,self.y)
				term.setTextColor(self.textColor)
				term.setBackgroundColor(self.backgroundColor)
				term.clearLine()
				self.value = read()
			end
			return true
		else
			return false
		end
	end
	
	function rtn_m:warn()
	
	end
	
	return rtn
end

function contextMenu(pItems,pX,pY,pID)
	local rtn = {}
	local rtn_m = {}
	rtn_m["__index"] = rtn_m

	setmetatable(rtn,rtn_m)
	rtn.items = pItems
	rtn.x = pX
	rtn.y = pY
	rtn.color = colors.white
	rtn.textColor = colors.black
	rtn.clicked = false
	rtn.len = #rtn.items
	rtn.wide = 0
	rtn.onClickActions = {}
	rtn.type = "contextMenu"
	rtn.id = pID

	for i,v in pairs(rtn.items) do
		if v:len() > rtn.wide then
			rtn.wide = v:len()
		end
	end

	rtn.wide = rtn.wide+1

	function rtn_m:draw()
		term.setCursorPos(self.x,self.y)
		for i=0,self.len-1 do
			paintutils.drawLine(self.x, self.y+i, self.x+self.wide, self.y+i, self.color)
		end
		term.setTextColor(self.textColor)
		for i=1,self.len do
			term.setCursorPos(self.x+1,self.y+(i-1))
			print(self['items'][i])
		end
	end

	function rtn_m:isClicked(pX,pY, ... )
		if pX >= self.x and pX <= self.x+self.wide and pY >= self.y and pY <= self.y+self.len then
			local obj = (pY - self.y)+1
			self.object = self.items[obj]
			self.clicked = true
			if self.onClickActions[self.object] then
				self.onClickActions(self.id, ... )
			end
			return true,self.object
		else
			self.clicked = false
			self.object = nil
			return false
		end
	end

	function rtn_m:addOnClick(pItem,pFkt)
		self.onClickActions[pItem] = pFkt
	end

	return rtn
end

function textToTable(allowNil, ... )
	local inp = { ... }
	local rtn = {}
	for i,v in ipairs(inp) do
		if v.type == "textField" then	
			if not allowNil and v.value == '' then
				v:warn()
				return nil
			end
			rtn[v.id] = v.value
		end
	end
	return rtn
end

function createSwitch(tElements,yPos,colorSelect,colorNormal,pID)
		--"Label"
	rtn = {}
	rtn_m = {}
	rtn_m["__index"] = rtn_m
	setmetatable(rtn,rtn_m)

	rtn.type = "switch"
	rtn.id = pID
	rtn.buttons = {}
	rtn.color = colorNormal
	rtn.colorSelect = colorSelect
	rtn.onClick = nil
	rtn.y = yPos

	for i=1,#tElements do
		local j = 1
		if rtn.buttons[i-1] then
			j = rtn.buttons[i-1].xEnd
		end
		table.insert(rtn.buttons,ui.button(tElements[i],j,yPos,rtn.color))
	end

	rtn.select = rtn.buttons[1]

	function rtn_m:draw()
		for i,v in pairs(self.buttons) do
			if self.select == v then
				v.color = self.colorSelect
			else
				v.color = self.color
			end
			v:draw()
		end
	end

	function rtn_m:value()
		return self.select.label
	end

	function rtn_m:isClicked(pX,pY)
		if self.y == pY then
			for i,v in pairs(self.buttons) do
				if v:isClicked(pX,pY) then
					self.select = v
					if self.onClick then
						self.onClick(self.select.value,self.select)
					end
					return true,self.select
				end
			end
		end
		return false,self.select
	end

	return rtn
end
