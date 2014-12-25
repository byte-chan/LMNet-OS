for _, v in pairs(rs.getSides()) do
	if peripheral.getType(v) == "modem" then
		rednet.open(v)
	end
end

running = true
rdnt = {}
local rdntmgr = {}

local function reloadCoroutineManager()
	local coroutineManager = loadfile(".lmnet/apis/comgr")
	setmetatable(rdntmgr, {__index = getfenv()})
	setfenv(coroutineManager, rdntmgr)()
end

reDirect = rdnt.goto
redirect = rdnt.goto
showBar = function() end
hideBar = function() end
themeColor = function() end
leftPrint = function(text)
	print(text)
end
lPrint = leftPrint
leftWrite = function(text)
	write(text)
end
lWrite = leftWrite
centerPrint = function(text)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	term.setCursorPos(math.floor(w/2-text:len()/2)+1, y)
	print(text)
end
cPrint = centerPrint
centerWrite = function(text)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	term.setCursorPos(math.floor(w/2-text:len()/2)+1, y)
	write(text)
end
cWrite = centerWrite
rightPrint = function(text)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	term.setCursorPos(w-text:len(), y)
	print(text)
end
rPrint = rightPrint
rightWrite = function(text)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	term.setCursorPos(w-text:len(), y)
	write(text)
end
rWrite = rightWrite

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
rdnt.title = "rdnt v1.1"
function rdnt.requestImpl(url)
	-- Not intended for regular use!
	-- Use rdnt.goto(url) to go to a URL.
	rednet.broadcast(url)
	local e = {rednet.receive(3)}
	if e[2] ~= nil then
		local file = fs.open(".sitetmp", "w")
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
			internalPage = url:sub(6)
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
			siteLoaded = true
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

local siteLoaded = false
local internalPage

function main()
	while running do
		if siteLoaded then
			siteLoaded = false
			dofile(".sitetmp")
		end
		if internalPage then
			internalPages[internalPage]()
			internalPage = nil
		end
		sleep(0)
	end
end

function rdntCmd()
	while true do
		e = {os.pullEvent()}
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
reloadCoroutineManager()
rdntmgr.addProcess(main)
rdntmgr.addProcess(rdntCmd)
rdntmgr.run()

clear()