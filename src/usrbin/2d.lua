local tArgs = {...}
if #tArgs < 1 then
	print("Usage: "..shell.getRunningProgram().." <map>")
	return
end

local mappath = shell.resolve(tArgs[1])

local mapfile = fs.open(mappath, "r")
if not mapfile then
	mapfile = fs.open(mappath, "w")
	mapfile.write(textutils.serialize({[0] = {[0] = 32768}}))
	mapfile.close()
end
mapfile = fs.open(mappath, "r")
local map = textutils.unserialize(mapfile.readAll()) or {[0] = {[0] = 32768}}
mapfile.close()
local pos = {x = 0, y = 0}

local w, h = term.getSize()

local parentterm = term.current()

term.setBackgroundColor(colors.black)
term.clear()

local currentBgColor = 32768

local function draw()
	local w, h = term.getSize()
	for _y = -math.floor(h/2)+1, math.floor(h/2) do
		for _x = -math.floor(w/2), math.floor(w/2) do
			term.setCursorPos(math.ceil(w/2)+_x, math.ceil(h/2)+_y)
			if not map[_x+pos.x] then
				map[_x+pos.x] = {}
			end
			if not map[_x+pos.x][_y+pos.y] then
				map[_x+pos.x][_y+pos.y] = 32768
			end
			if currentBgColor ~= map[_x+pos.x][_y+pos.y] then
				term.setBackgroundColor(map[_x+pos.x][_y+pos.y])
				currentBgColor = map[_x+pos.x][_y+pos.y]
			end
			term.setTextColor(map[_x+pos.x][_y+pos.y] == 1 and 32768 or 1)
			if _x == 0 and _y == 0 then
				write("x")
			else
				write(" ")
			end
		end
	end
	term.setCursorPos(2, 1)
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.white)
	term.clearLine()
	write("2d version 1.0")
	term.setCursorPos(math.ceil(w/2)-tostring(pos.x):len(), 1)
	write(tostring(pos.x))
	write("|")
	write(tostring(pos.y))
	term.setBackgroundColor(colors.black)
end

local running = true

local function exit()
	mapfile = fs.open(mappath, "w")
	mapfile.write(textutils.serialize(map))
	mapfile.close()
	running = false
	term.clear()
	term.setCursorPos(1, 1)
	sleep(0.1)
end

local redraw = true

while running do
	if redraw then draw() end
	redraw = false
	local e = {os.pullEventRaw()}
	if e[1] == "terminate" then
		exit()
	elseif e[1] == "key" then
		if e[2] == keys.q then
			exit()
		elseif e[2] == keys.left then
			pos.x = pos.x - 1
			redraw = true
		elseif e[2] == keys.right then
			pos.x = pos.x + 1
			redraw = true
		elseif e[2] == keys.up then
			pos.y = pos.y - 1
			redraw = true
		elseif e[2] == keys.down then
			pos.y = pos.y + 1
			redraw = true
		elseif e[2] == keys.space then
			if not map[pos.x][pos.y] or map[pos.x][pos.y] == 32768 then
				map[pos.x][pos.y] = 1
				redraw = true
			end
		elseif e[2] == keys.leftShift then
			if map[pos.x][pos.y] == 1 then
				map[pos.x][pos.y] = 32768
				redraw = true
			end
		end
	end
end
