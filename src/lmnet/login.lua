-- LMNet OS login system

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
	else
		while true do
			clear()
			write("       Password: ")
			setCursor(1, 2)
			write("Repeat password: ")
			setCursor(18, 1)
			local pass = read("*")
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
	end
end
-- load .lmnet/users.db