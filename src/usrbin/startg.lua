-- WIP: window system with multitasking
-- need multishell T_T
-- this is getting worse
-- i need more multishell
-- or craftos 1.6
-- I CAN HAS MULTISHELLZ?
-- THIS IS TEMPORARY
-- REPLACE CONTENTS OF THIS FILE WITH MULTISHELL!
-- FML!
-- WHAT IS THIS SHIT

print("LMNet window system G")
if not lmnet then
	print("Error: not running in LMNet OS")
	return
end
print("Initializing environment...")

windowCount = 0

windows = {}
function newWindow(title, func)
	local newenv = {}
	for i, v in pairs(_G) do
		if i ~= "_G" or i ~= "package" then
			if type(v) == "table" then
				local tbl = {}
				for i2, v2 in pairs(_G[i]) do
					tbl[i2] = v2
				end
				newenv[i] = tbl
			else
				newenv[i] = v
			end
		end
	end
	newenv["_G"] = newenv
	newenv["window"] = windows[windowCount + 1]
	windowCount = windowCount + 1
	setfenv(func, newenv)
	table.insert(windows, {
		func = func
	})
	windows[windowCount].routine = coroutine.create(windows[windowCount].func)
end

-- some parallel code XD

function runWindows()
	local tFilters = {}
	local eventData = {}
	while windowCount > 0 do
		for n=1,#windows do
			local r = windows[n].routine
			if r then
				if tFilters[r] == nil or tFilters[r] == eventData[1] or eventData[1] == "terminate" then
					local ok, param = coroutine.resume( r, unpack(eventData) )
					if not ok then
						error( param )
					else
						tFilters[r] = param
					end
					if coroutine.status( r ) == "dead" then
						table.remove(windows, n)
						windowCount = windowCount - 1
					end
				end
			end
		end
		for n=1,#windows do
			local r = windows[n]
			if r and coroutine.status( r ) == "dead" then
				table.remove(windows, n)
				windowCount = windowCount - 1
			end
		end
		eventData = { os.pullEventRaw() }
	end
end

print("Creating shell window (bash)")
newWindow("Shell", function() shell.run("bash") end)
print("Connecting")
clear()
runWindows()