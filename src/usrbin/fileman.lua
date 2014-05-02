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
				elseif selectedAction == "Delete" then
					fs.delete(shell.resolve(selected))
				end
			end
		else
			local selectedAction = ui.menu({"Run", "Edit", "Delete", "Move", "Copy", "New"}, "Actions for /"..shell.resolve(selected))
			if selectedAction then
				if selectedAction == "Run" then
					shell.run(selected)
				elseif selectedAction == "Edit" then
					shell.run("edit \""..selected.."\"")
				elseif selectedAction == "Delete" then
					fs.delete(shell.resolve(selected))
				end
			end
		end
	end
end

local running = true
while running do
	local selection = files()
	if not selection then
		running = false
	end
	sleep(0)
end