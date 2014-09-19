-- LMLua - LMNet lua interpreter

local lmlua_env = {
	["exit"] = function()
		running = nil
	end
}

setmetatable(lmlua_env, {__index = getfenv()})

local tArgs = {...}
if #tArgs > 0 then
	for i = 1, #tArgs do
		local func, err = loadfile(tArgs[i])
		if not func then
			print(err)
		else
			setfenv(func, lmlua_env)
			func()
		end
	end
	return
end

running = true
local lmlua_history = {}

print("LMLua interpreter")
print("Call exit() to exit.")
while running do
	write("lmlua> ")
	local input = read(nil, lmlua_history)
	table.insert(lmlua_history, input)
	local nForcePrint = 0
	local func, e = loadstring(input, "lmlua")
	local func2, e2 = loadstring("return "..input, "lmlua")
	if not func then
		if func2 then
			func = func2
			e = nil
			nForcePrint = 1
		end
	else
		if func2 then
			func = func2
		end
	end
	if func then
		setfenv(func, lmlua_env)
		local tResults = {pcall( function() return func() end )}
		if tResults[1] then
			local n = 1
			while (tResults[n + 1] ~= nil) or (n <= nForcePrint) do
				print(tostring(tResults[n + 1]))
				n = n + 1
			end
		else
			print(tResults[2])
		end
	else
		print(e)
	end
	sleep(0)
end