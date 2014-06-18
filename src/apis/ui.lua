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
