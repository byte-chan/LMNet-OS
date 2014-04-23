for _, v in pairs(rs.getSides()) do
	if peripheral.getType(v) == "modem" then
		rednet.open(v)
	end
end

running = true
rdnt = {}

function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

function iif(cond, trueval, falseval)
	if cond then
		return trueval
	else
		return falseval
	end
end

function rdnt.bgColor(color)
	if term.isColor() or color == colors.white or color == colors.black then
		term.setBackgroundColor(color)
	end
end

function rdnt.fgColor(color)
	if term.isColor() or color == colors.white or color == colors.black then
		term.setTextColor(color)
	end
end

function rdnt.clear()
	term.clear()
	term.setCursorPos(1, 1)
	rdnt.bgColor(colors.gray)
	term.clearLine()
	print("URL: "..rdnt.currentURL)
	rdnt.bgColor(colors.black)
	term.setCursorPos(1, 2)
end
rdnt.title = "rdnt v1.0"
function rdnt.requestImpl(url)
	-- Not intended for regular use!
	-- Use rdnt.goto(url) to go to a URL.
	rednet.broadcast(url)
	local e = {rednet.receive(3)}
	if e[2] ~= nil then
		local file = fs.open("/.sitetmp", "w")
		file.write(e[2])
		file.close()
		return true
	else
		return false
	end
end
function rdnt.goto(url)
	rdnt.tryURL = url
	if url:sub(1, 5) == "rdnt." then
		if internalPages[url:sub(6)] ~= nil then
			rdnt.currentURL = url
			rdnt.clear()
			internalPages[url:sub(6)]()
		else
			rdnt.clear()
			print("No internal page '"..url:sub(6).."'.")
		end
	else
		rdnt.clear()
		print("Connecting to '"..url.."'...")
		local ok = rdnt.requestImpl(url)
		if ok then
			rdnt.currentURL = url
			rdnt.clear()
			shell.run("/.sitetmp")
		else
			rdnt.clear()
			print("Failed to connect to '"..url.."'.")
			print("Ask the server administrator to fix this problem.")
		end
	end
end
function rdnt.home()
	rdnt.goto(rdnt.homeURL)
end

internalPages = {
	["home"] = function()
		rdnt.clear()
		print("Welcome to rdnt!")
		print("Press left Ctrl to enter a URL.")
		print("Enter rdnt.intpages to view internal pages.")
		print("Enter rdnt.exit to exit.")
		print("Press F5 to refresh.")
	end,
	["exit"] = function()
		running = false
	end,
	["intpages"] = function()
		rdnt.clear()
		print("Internal pages in rdnt:")
		for v in pairs(internalPages) do
			textutils.pagedPrint("- "..v)
		end
	end
}

function main()
	while running do
		sleep(0)
	end
end
function rdntCmd()
	while true do
		e = {os.pullEvent("key")}
		if e[1] == "key" then
			if e[2] == keys.leftCtrl then
				term.setCursorPos(1, 1)
				rdnt.bgColor(colors.red)
				term.clearLine()
				write("URL: ")
				local input = read()
				rdnt.bgColor(colors.black)
				term.clearLine()
				rdnt.goto(input)
			elseif e[2] == keys.f5 then
				rdnt.goto(rdnt.tryURL)
			end
		end
		sleep(0)
	end
end

rdnt.homeURL = "rdnt.home"
rdnt.tryURL = ""
rdnt.currentURL = ""
rdnt.home()
parallel.waitForAny(main, rdntCmd)

clear()