function show(items, title)
	local function clear()
		term.clear()
		term.setCursorPos(1, 1)
	end
	
	local function cprint(text)
		setCursor(math.floor(getSize().x/2)-math.floor(text:len()/2), getCursor().y)
		print(text)
	end
	
	local function maxPages()
		local itemCount = #items
		local pageCount = 0
		while itemCount > 0 do
			itemCount = itemCount - 10
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
			for j = 10*(i-1)+1, iif(10*(i+1) > #items, #items, 10*(i+1)) do
				if nElements < 10 then
					table.insert(tmp, items[j])
					nElements = nElements + 1
				end
			end
			table.insert(ret, tmp)
		end
		return ret
	end
	
	local selected = 1
	local page = 1
	
	local function redraw()
		term.setBackgroundColor(colors.black)
		clear()
		cprint(title)
		print("Select with arrow keys.")
		print("Press enter to select.")
		print("Terminate to cancel.")
		print("(page "..page.." of "..maxPages()..")")
		for i = 1, #pagedItems()[page] do
			if selected == 10*(page-1)+i then
				term.setBackgroundColor(colors.white)
				term.setTextColor(colors.black)
			else
				term.setBackgroundColor(colors.black)
				term.setTextColor(colors.white)
			end
			term.clearLine()
			print(iif(selected == 10*(page-1)+i, ">", " ").." "..pagedItems()[page][i])
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.white)
		end
	end
	
	while true do
		redraw()
		local eventData = {os.pullEventRaw()}
		if eventData[1] == "terminate" then
			clear()
			return nil
		elseif eventData[1] == "key" then
			if eventData[2] == keys.up and selected > 1 then
				selected = selected - 1
				if selected-(page-1)*10 < 1 then
					page = page - 1
				end
			elseif eventData[2] == keys.down and selected < #items then
				selected = selected + 1
				if selected-(page-1)*10 > 10 then
					page = page + 1
				end
			elseif eventData[2] == keys.enter then
				clear()
				return items[selected]
			elseif eventData[2] == keys.left and page > 1 then
				page = page - 1
				if selected - 10 < 1 then
					selected = 1
				else
					selected = selected - 10
				end
			elseif eventData[2] == keys.right and page < maxPages() then
				page = page + 1
				if selected + 10 > #items then
					selected = #items
				else
					selected = selected + 10
				end
			end
		end
		sleep(0)
	end
end