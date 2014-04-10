local tArgs = {...}
if #tArgs < 1 then
	print("Usage: loader args [args ...]")
	print("Arg format:")
	print("mode=par;par;...")
	print("Modes: shell (run program), api (load as API)")
	return
end

local function api(filename, loadas)
	local fenv = {}
	setmetatable(fenv, {__index = _G})
	local func, err = loadfile(filename)
	if func then
		setfenv(func, fenv)
		func()
	else
		print("Load "..loadas.." failed: "..err)
		return
	end
	local api = {}
	for i, v in pairs(fenv) do
		api[i] =  v
	end
	_G[loadas] = api
end

local newArgs = {}

for i = 1, #tArgs do
	local matches = {}
	for match in string.gmatch(tArgs[i], "[^=;]+") do
		table.insert(matches, match)
	end
	table.insert(newArgs, {argType = matches[1], par = {unpack(matches, 2)}})
end
for _, v in pairs(newArgs) do
	if v.argType == "api" then
		api(unpack(v.par))
	elseif v.argType == "shell" then
		shell.run(unpack(par))
	end
end