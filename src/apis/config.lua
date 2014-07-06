function read(cfgfile, cfg)
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
end
function write(cfgfile, cfg, value)
	local path
	if not cfgfile then
		path = "/.lmnet/sys.conf"
	else
		path = cfgfile
	end
	if fs.exists(path) and fs.isDir(path) then
		error(path.." is a directory", 0)
	end
	local readfile = fs.open(path, "r")
	if readfile then
		local readlines = {}
		local readline = ""
		while readline ~= nil do
			readline = readfile.readLine()
			if readline then
				table.insert(readlines, readline)
			end
		end
		readfile.close()
	end
	local config = {}
	if fs.exists(path) and not fs.isDir(path) then
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
	end
	local writefile = fs.open(path, "w")
	config[cfg] = value
	table.sort(config)
	for i, v in pairs(config) do
		writefile.writeLine(i.."="..textutils.serialize(v))
	end
	writefile.close()
end
function list(cfgfile)
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
