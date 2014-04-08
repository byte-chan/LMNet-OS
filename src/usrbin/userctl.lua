if not fs then
	print("Not running in CraftOS.")
	return
end

-- load .lmnet/users.db
local file = fs.open("/.lmnet/users.db", "r")
local users = textutils.unserialize(file.readAll())
file.close()

local function cprint(text)
	setCursor(math.floor(getSize().x/2)-math.floor(text:len()/2), getCursor().y)
	print(text)
end

local function maxPages()
	local userCount = #users
	local pageCount = 0
	while userCount > 0 do
		userCount = userCount - 10
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

local function pagedUsers()
	local ret = {}
	for i = 1, maxPages() do
		local tmp = {}
		local nElements = 0
		for j = 10*(i-1)+1, iif(10*(i+1) > #users, #users, 10*(i+1)) do
			if nElements < 10 then
				table.insert(tmp, users[j].user)
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
	clear()
	cprint("LMNet OS: User control")
	print("Select user with arrow keys.")
	print("Modes:")
	print("(a)dd, (d)elete, (c)hange password, (m)ove user")
	print("Q to exit.")
	write("(page ")
	write(page)
	write(" of ")
	write(maxPages())
	print(")")
	for i = 1, #pagedUsers()[page] do
		print(iif(selected == 10*(page-1)+i, "x", " ").." "..pagedUsers()[page][i])
	end
end

function selectUser()
	while true do
		redraw()
		local eventData = {os.pullEventRaw()}
		if eventData[1] == "terminate" then
			clear()
			print("Exiting.")
			sleep(1)
			running = false
			return
		elseif eventData[1] == "key" then
			if eventData[2] == keys.up and selected > 1 then
				selected = selected - 1
				if selected-(page-1)*10 < 1 then
					page = page - 1
				end
			elseif eventData[2] == keys.down and selected < #users then
				selected = selected + 1
				if selected-(page-1)*10 > 10 then
					page = page + 1
				end
			elseif eventData[2] == keys.enter then
				return selected
			elseif eventData[2] == keys.left and page > 1 then
				page = page - 1
				if selected - 10 < 1 then
					selected = 1
				else
					selected = selected - 10
				end
			elseif eventData[2] == keys.right and page < maxPages() then
				page = page + 1
				if selected + 10 > #users then
					selected = #users
				else
					selected = selected + 10
				end
			elseif eventData[2] == keys.q then
				running = false
				return
			end
		end
		sleep(0)
	end
end

function moveUser()
	while true do
		redraw()
		local eventData = {os.pullEventRaw()}
		if eventData[1] == "terminate" then
			clear()
			print("Exiting.")
			sleep(1)
			running = false
			return
		elseif eventData[1] == "key" then
			if eventData[2] == keys.up and selected > 1 then
				selected = selected - 1
				users[selected+1], users[selected] = users[selected], users[selected+1]
				if selected-(page-1)*10 < 1 then
					page = page - 1
				end
			elseif eventData[2] == keys.down and selected < #users then
				selected = selected + 1
				users[selected-1], users[selected] = users[selected], users[selected-1]
				if selected-(page-1)*10 > 10 then
					page = page + 1
				end
			elseif eventData[2] == keys.enter then
				return
			elseif eventData[2] == keys.left and page > 1 then
				page = page - 1
				if selected - 10 < 1 then
					users[selected], users[1] = users[1], users[selected]
					selected = 1
				else
					users[selected], users[selected-10] = users[selected-10], users[selected]
					selected = selected - 10
				end
			elseif eventData[2] == keys.right and page < maxPages() then
				page = page + 1
				if selected + 10 > #users then
					users[selected], users[#users] = users[#users], users[selected]
					selected = #users
				else
					users[selected], users[selected+10] = users[selected+10], users[selected]
					selected = selected + 10
				end
			end
		end
		sleep(0)
	end
end

moveUser()