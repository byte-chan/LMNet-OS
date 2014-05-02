local tArgs = {...}
if #tArgs < 1 then
 print("Usage: remotecl <id>")
 return
end

local modems = false
for _, v in pairs(rs.getSides()) do
 if peripheral.isPresent(v) and peripheral.getType(v) == "modem" then
  rednet.open(v)
  modems = true
 end
end

local turtleID = tonumber(tArgs[1])
if not turtleID then
 printError("Turtle ID not a number")
 return
end

if not modems then
 printError("No modems attached")
 return
end

local running = true
while running do
 local e, k = os.pullEvent("key")
 if k == keys.q then
  running = false
 else
  rednet.send(turtleID, k)
 end
end