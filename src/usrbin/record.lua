local helpMsg = {
	"record v1.0 by MultMine",
	"Usage: record <output> [program]",
	"When using shell, type exit to stop recording.",
}

local tArgs = {...}
if #tArgs < 1 then
	print(table.concat(helpMsg))
	return
end

local logpath = shell.resolve(tArgs[1])

local function append(text)
	local f = fs.open(logpath, "a")
	f.writeLine(text)
	f.close()
end

local parentTerm = term.current()

local redirect = {}
setmetatable(redirect, {__index = function(self, k)
	if parentTerm[k] then
		return function(...)
			local newArgs = {}
			for i, v in ipairs({...}) do
				table.insert(newArgs, textutils.serialize(v))
			end
			if k ~= "isColor" and k ~= "isColour" and k ~= "getCursorPos" and k ~= "getSize" then
				append("term."..k.."("..table.concat(newArgs,",")..")")
			end
			return parentTerm[k](...)
		end
	end
end})

local oldPE = os.pullEvent
os.pullEvent = function(filter)
	local startTime = os.clock()
	local ev = {oldPE(filter)}
	local evDelay = os.clock() - startTime
	if evDelay >= 0.05 then
		append("sleep("..evDelay..")")
	end
	return unpack(ev)
end

pcall(function()
	term.redirect(redirect)
	term.clear()
	term.setCursorPos(1, 1)
	shell.run(tArgs[2] or "shell")
end)

os.pullEvent = oldPE
term.redirect(parentTerm)
