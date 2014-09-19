if not turtle then
 printError("Not a turtle")
 return
end

local modems = false
for _, v in pairs(rs.getSides()) do
 if peripheral.isPresent(v) and peripheral.getType(v) == "modem" then
  rednet.open(v)
  modems = true
 end
end

if not modems then
 printError("No modems attached")
 return
end

local tArgs = {...}

if not fs.exists(".remoteBind") or (#tArgs > 0 and tArgs[1] == "--rebind") then
 print("Bind this turtle to another computer.")
 write("ID: ")
 local input = tonumber(read())
 if not input then
  print("Not a number.")
  return
 end
 local file = fs.open(".remoteBind", "w")
 file.write(tostring(input))
 file.close()
 print("Bound to computer ID "..input..".")
end

local file = fs.open(".remoteBind", "r")
local boundID = tonumber(file.readAll())
file.close()

local direction = "front"
local function setUp()
 direction = "up"
end
local function setFront()
 direction = "front"
end
local function setDown()
 direction = "down"
end
local function dig()
 if direction == "up" then
  turtle.digUp()
 elseif direction == "front" then
  turtle.dig()
 elseif direction == "down" then
  turtle.digDown()
 end
end
local function place()
 if direction == "up" then
  turtle.placeUp()
 elseif direction == "front" then
  turtle.place()
 elseif direction == "down" then
  turtle.placeDown()
 end
end
local function slotUp()
 if turtle.getSelectedSlot() == 16 then
  turtle.select(1)
 else
  turtle.select(turtle.getSelectedSlot()+1)
 end
end
local function slotDown()
 if turtle.getSelectedSlot() == 1 then
  turtle.select(16)
 else
  turtle.select(turtle.getSelectedSlot()-1)
 end
end

local commands = {
 [keys.up] = turtle.forward,
 [keys.down] = turtle.back,
 [keys.left] = turtle.turnLeft,
 [keys.right] = turtle.turnRight,
 [keys.w] = turtle.up,
 [keys.s] = turtle.down,
 [keys.leftCtrl] = place,
 [keys.leftShift] = dig,
 [keys.equals] = slotUp,
 [keys.minus] = slotDown,
 [keys.numPad8] = setUp,
 [keys.numPad5] = setFront,
 [keys.numPad2] = setDown,
 [keys.space] = turtle.attack,
}

local running = true
while running do
 local id, msg = rednet.receive()
 if id == boundID then
  for i, v in pairs(commands) do
   if tonumber(msg) == i then
    v()
   end
  end
 end
end