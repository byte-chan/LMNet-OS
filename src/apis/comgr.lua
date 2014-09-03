local processList = {}
local exit = false
local noAutoExit = false
function setAutoExit(val)
	noAutoExit = not val
end
function forceExit()
	exit = true
end
function run()
	exit = false
	while (function()
		local rtn = false
		for i, co in ipairs(processList) do
			if coroutine.status(co) ~= "dead" then
				rtn = true
			end
		end
		return rtn
	end)() or noAutoExit do
		if exit then
			return
		end
		if #processList > 0 then
			local event = {os.pullEventRaw()}
			for i, co in ipairs(processList) do
				if coroutine.status(co) ~= "dead" then
					coroutine.resume(co, unpack(event))
				end
			end
		end
	end
end
function addProcess(func)
	table.insert(processList, coroutine.create(func))
	return #processList
end
function removeProcess(id)
	table.remove(processList, id)
end
