if not turtle then
	printError("Not a turtle")
	return
end

local makerbotActions = {
	floor = function(...)
		local tArgs = {...}
		if #tArgs < 2 then
			return false, "Not enough arguments, 2 required", "Width, depth"
		end
		local width = tArgs[1]
		local depth = tArgs[2]
		for x = 1, width do
			for z = 1, depth do
				while turtle.getItemCount() < 1 do
					turtle.select(turtle.getSelectedSlot()+1)
				end
				if turtle.detectDown() and not turtle.compareDown() then
					turtle.digDown()
				end
				if not turtle.detectDown() then
					turtle.placeDown()
				end
				turtle.forward()
			end
			for z = 1, depth do
				turtle.back()
			end
			turtle.turnRight()
			turtle.forward()
			turtle.turnLeft()
		end
		turtle.turnLeft()
		for x = 1, width do
			turtle.forward()
		end
		turtle.turnRight()
		return true
	end,
	walls = function(...)
		local tArgs = {...}
		if #tArgs < 3 then
			return false, "Not enough arguments, 3 required", "Width, depth, height"
		end
		local width = tonumber(tArgs[1])
		local depth = tonumber(tArgs[2])
		local height = tonumber(tArgs[3])
		for y = 1, height do
			turtle.up()
			for _ = 1, 2 do
				for z = 1, depth do
					while turtle.getItemCount() < 1 do
						turtle.select(turtle.getSelectedSlot()+1)
					end
					if turtle.detectDown() and not turtle.compareDown() then
						turtle.digDown()
					end
					if not turtle.detectDown() then
						turtle.placeDown()
					end
					turtle.forward()
				end
				turtle.back()
				turtle.turnRight()
				for z = 1, width do
					while turtle.getItemCount() < 1 do
						turtle.select(turtle.getSelectedSlot()+1)
					end
					if turtle.detectDown() and not turtle.compareDown() then
						turtle.digDown()
					end
					if not turtle.detectDown() then
						turtle.placeDown()
					end
					turtle.forward()
				end
				turtle.back()
				turtle.turnRight()
			end
		end
	end,
	cuboid = function(...)
		local tArgs = {...}
		if #tArgs < 3 then
			return false, "Not enough arguments, 3 required", "Width, height, depth"
		end
		local width = tonumber(tArgs[1])
		local depth = tonumber(tArgs[2])
		local height = tonumber(tArgs[3])
		for x = 1, width do
			for z = 1, depth do
				while turtle.getItemCount() < 1 do
					turtle.select(turtle.getSelectedSlot()+1)
				end
				if turtle.detectDown() and not turtle.compareDown() then
					turtle.digDown()
				end
				if not turtle.detectDown() then
					turtle.placeDown()
				end
				turtle.forward()
			end
			for z = 1, depth do
				turtle.back()
			end
			turtle.turnRight()
			turtle.forward()
			turtle.turnLeft()
		end
		turtle.turnLeft()
		for x = 1, width do
			turtle.forward()
		end
		turtle.turnRight()
		
		if height > 2 then
			for y = 1, height-2 do
				turtle.up()
			for _ = 1, 2 do
				for z = 1, depth do
					while turtle.getItemCount() < 1 do
						turtle.select(turtle.getSelectedSlot()+1)
					end
					if turtle.detectDown() and not turtle.compareDown() then
						turtle.digDown()
					end
					if not turtle.detectDown() then
						turtle.placeDown()
					end
					turtle.forward()
				end
				turtle.back()
				turtle.turnRight()
				for z = 1, width do
					while turtle.getItemCount() < 1 do
						turtle.select(turtle.getSelectedSlot()+1)
					end
					if turtle.detectDown() and not turtle.compareDown() then
						turtle.digDown()
					end
					if not turtle.detectDown() then
						turtle.placeDown()
					end
					turtle.forward()
				end
				turtle.back()
				turtle.turnRight()
			end
		end
		
		for x = 1, width do
			for z = 1, depth do
				while turtle.getItemCount() < 1 do
					turtle.select(turtle.getSelectedSlot()+1)
				end
				if turtle.detectDown() and not turtle.compareDown() then
					turtle.digDown()
				end
				if not turtle.detectDown() then
					turtle.placeDown()
				end
				turtle.forward()
			end
			for z = 1, depth do
				turtle.back()
			end
			turtle.turnRight()
			turtle.forward()
			turtle.turnLeft()
		end
		turtle.turnLeft()
		for x = 1, width do
			turtle.forward()
		end
		turtle.turnRight()
		return true
	end
}

local function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

clear()
print("Makerbot 1.0")
print("Building utility for mining turtles")
local tArgs = {...}
if #tArgs < 1 then
	print("Commands:")
	for command in pairs(makerbotActions) do
		print("- "..command)
	end
	return
end

local cmdReturn = {makerbotActions[tArgs[1]](unpack(tArgs, 2))}
if cmdReturn[1] then
	print("OK.")
else
	write("Error: ")
	for i = 2, #cmdReturn do
		print(cmdReturn[i])
	end
end