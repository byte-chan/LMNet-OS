if not fs then
	print("Not running in CraftOS.")
	return
end

-- LMNet OS login system

--[[
function clear()
	term.clear()
	term.setCursorPos(1, 1)
end
]]

if not fs.exists("/.lmnet/users.db") then
	local file = fs.open("/.lmnet/users.db", "w")
	clear()
	print("Welcome to LMNet OS!")
	print("This program will help you to set up the users.")
	write("Do you want to create user accounts? [Yn] ")
	local input = string.lower(read())
	local users = {}
	if input == "y" or input == "" then
		local creatingUsers = true
		while creatingUsers do
			clear()
			print("Create user accounts")
			print("Created accounts:")
			for _, v in pairs(users) do
				print("- "..v.user)
			end
			print("")
			write("User (blank to stop): ")
			local user = read()
			for _, v in pairs(users) do
				if v.user == user then
					print("No duplicates allowed.")
					return
				end
			end
			if user == "" then
				creatingUsers = false
			else
				write("Password: ")
				local pass = read("*")
				write("  Repeat: ")
				local passRepeat = read("*")
				if pass ~= passRepeat then
					print("Passwords don't match.")
					sleep(1.5)
				else
					table.insert(users, {user = user, pass = pass})
				end
			end
		end
	end
	clear()
	write("Add a password for root account? [Yn] ")
	input = string.lower(read())
	if input ~= "y" and input ~= "" then
		clear()
		print("Setting no password for root.")
		table.insert(users, {user = "root", pass = ""})
	else
		local pass
		while true do
			clear()
			write("       Password: ")
			setCursor(1, 2)
			write("Repeat password: ")
			setCursor(18, 1)
			pass = read("*")
			setCursor(18, 2)
			local passRepeat = read("*")
			if pass ~= passRepeat then
				clear()
				print("Passwords don't match.")
				sleep(1.5)
			else
				break
			end
		end
		table.insert(users, {user = "root", pass = pass})
	end
	file.write(textutils.serialize(users))
	file.close()
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
	bgSet(colors.gray)
	term.clearLine()
	cprint((os.version())..": Login")
	bgSet(colors.black)
	print("Select user with arrow keys.")
	print("Press enter to select.")
	print("Q to shut down.")
	write("(page ")
	write(page)
	write(" of ")
	write(maxPages())
	print(")")
	for i = 1, #pagedUsers()[page] do
		if selected == 10*(page-1)+i then
			bgSet(colors.white)
			fgSet(colors.black)
		else
			bgSet(colors.black)
			fgSet(colors.white)
		end
		term.clearLine()
		print(iif(selected == 10*(page-1)+i, ">", " ").." "..pagedUsers()[page][i])
		bgSet(colors.black)
		fgSet(colors.white)
	end
end

local oldPullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local tArgs = {...}

if config.read(nil, "autoLogin") and tArgs[1] ~= "--switch" then
	currentUser = config.read(nil, "autoLogin")
	os.pullEvent = oldPullEvent
	if fs.exists(fs.combine(currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser), "startup")) then
		clear()
		shell.run("\""..fs.combine(currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser), "startup").."\"")
		print("Press any key to continue")
		os.pullEvent("key")
	end
end

if config.read(nil, "classicLogin") then
	clear()
	while currentUser == "login" do
		print("")
		print(os.version())
		print("")
		write(config.read(nil, "hostname").. " login: ")
		local inputUser = read()
		local success = false
		for _, v in pairs(users) do
			if v.user == inputUser then
				if v.pass ~= "" and v.pass ~= nil then
					write("Password for "..inputUser..": ")
					local inputPass = read("")
					if inputPass == v.pass then
						success = true
						break
					else
						print("Incorrect password")
					end
				else
					success = true
				end
			end
		end
		if success then
			currentUser = users[selected].user
			os.pullEvent = oldPullEvent
			if fs.exists(fs.combine(currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser), "startup")) then
				clear()
				shell.run(fs.combine("\""..currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser), "startup").."\"")
				print("Press any key to continue")
				os.pullEvent("key")
			end
		end
	end
else
	while currentUser == "login" do
		redraw()
		local eventData = {os.pullEventRaw()}
		if eventData[1] == "terminate" then
			clear()
			print("Termination is not allowed.")
			sleep(2)
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
				if users[selected].pass ~= "" then
					clear()
					write("Password for "..users[selected].user..": ")
					local input = read("*")
					if users[selected].pass ~= input then
						print("Wrong password.")
						sleep(1.5)
					else
						currentUser = users[selected].user
						os.pullEvent = oldPullEvent
						if fs.exists(fs.combine(currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser), "startup")) then
							clear()
							shell.run(fs.combine("\""..currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser), "startup").."\"")
							print("Press any key to continue")
							os.pullEvent("key")
						end
					end
				else
					currentUser = users[selected].user
					os.pullEvent = oldPullEvent
					if fs.exists(fs.combine(currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser), "startup")) then
						clear()
						shell.run("\""..fs.combine(currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser), "startup").."\"")
						print("Press any key to continue")
						os.pullEvent("key")
					end
				end
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
				clear()
				shell.run("/rom/programs/shutdown")
			end
		end
		sleep(0)
	end
	clear()
end
if currentUser == "login" then
	os.reboot()
end
