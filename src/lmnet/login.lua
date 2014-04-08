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
		for j = 10*(i-1)+1, iif(10*(i) > #users, #users, 10*(i+1)) do
			table.insert(tmp, users[j].user)
		end
		table.insert(ret, tmp)
	end
	return ret
end

local selected = 1
local page = 1

local function redraw()
	clear()
	cprint("LMNet OS: Login")
	print("Select user with arrow keys.")
	print("Press enter to select.")
	print("Q to shut down.")
	write("(page ")
	write(page)
	write(" of ")
	write(maxPages())
	print(")")
	for i = 1, #pagedUsers()[page] do
		print(iif(selected == 10*(page-1)+i, "x", " ").." "..pagedUsers()[page][i])
	end
end

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
		elseif eventData[2] == keys.down and selected < #users then
			selected = selected + 1
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
				end
			else
				currentUser = users[selected].user
			end
		elseif eventData[2] == keys.left and page > 1 then
			page = page - 1
		elseif eventData[2] == keys.right and page < maxPages() then
			page = page + 1
		elseif eventData[2] == keys.q then
			clear()
			shell.run("/rom/programs/shutdown")
		end
	end
	sleep(0)
end