-- LMLua - LMNet lua interpreter

local lmlua_env = {
	sysconfig = {
		read = function(cfgfile, cfg)
			local path
			if not cfgfile then
				path = "/.lmnet/sys.conf"
			else
				path = cfgfile
			end
			local file = fs.open(path, "r")
			if not file then
				return nil
			end
			local lines = {}
			local line = ""
			while line ~= nil do
				line = file.readLine()
				if line then
					table.insert(lines, line)
				end
			end
			file.close()
			local config = {}
			for _, v in pairs(lines) do
				local tmp
				local tmp2 = ""
				for match in string.gmatch(v, "[^\=]+") do
					if tmp then
						tmp2 = tmp2..match
					else
						tmp = match
					end
				end
				config[tmp] = textutils.unserialize(tostring(tmp2))
			end
			for i, v in pairs(config) do
				if i == cfg then
					return v
				end
			end
			return nil
		end,
		write = function(cfgfile, cfg, value)
			local path
			if not cfgfile then
				path = "/.lmnet/sys.conf"
			else
				path = cfgfile
			end
			local readfile = fs.open(path, "r")
			if not readfile then
				return nil
			end
			local readlines = {}
			local readline = ""
			while readline ~= nil do
				readline = readfile.readLine()
				if readline then
					table.insert(readlines, readline)
				end
			end
			readfile.close()
			local config = {}
			for _, v in pairs(readlines) do
				local tmp
				local tmp2 = ""
				for match in string.gmatch(v, "[^\=]+") do
					if tmp then
						tmp2 = tmp2..match
					else
						tmp = match
					end
				end
				config[tmp] = textutils.unserialize(tostring(tmp2))
			end
			local writefile = fs.open(path, "w")
			config[cfg] = value
			table.sort(config)
			for i, v in pairs(config) do
				writefile.writeLine(i.."="..textutils.serialize(v))
			end
			writefile.close()
		end,
		list = function(cfgfile)
			local path
			if not cfgfile then
				path = "/.lmnet/sys.conf"
			else
				path = cfgfile
			end
			local file = fs.open(path, "r")
			if not file then
				return nil
			end
			local lines = {}
			local line = ""
			while line ~= nil do
				line = file.readLine()
				if line then
					table.insert(lines, line)
				end
			end
			file.close()
			local config = {}
			for _, v in pairs(lines) do
				local tmp
				local tmp2 = ""
				for match in string.gmatch(v, "[^\=]+") do
					if tmp then
						tmp2 = tmp2..match
					else
						tmp = match
					end
				end
				config[tmp] = textutils.unserialize(tostring(tmp2))
			end
			return config
		end
	},
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
end