local tArgs = { ... }
if not git then
	error("Git API not found!",0)
end

local function toboolean(pI)
	if pI ~= nil then
		if pI == '1' or pI:lower() == 'true' or pI:lower() == 't' then
			return true
		else
			return false
		end
	else 
		return false 
	end
end

local function simpleReq(pUrl)
	local req = http.get(pUrl)
	if req then
		local res = req.readAll()
		req.close()
		return res
	end
end

local function printUsage()
	printError("gists get <id> [<hide .lua (0,1)>] [<overwrite (0,1)>]")
	printError("gists put <file1> <filetwo>")
end

local function forkID(pId,pDel,pHide)
	local gist = git.gists(pId)
	print('Gist by '..gist.owner.login)
	print(gist.description)
	for i,v in pairs(gist.files) do
		local fN
		if i:sub(i:len()-3,i:len()) == ".lua" and pHide then
			fN = fs.combine(shell.dir(),i:sub(1,i:len()-4))
		else
			fN = fs.combine(shell.dir(),i)
		end
		if not fs.exists(fN) or pDel then
			local f = fs.open(fN,"w")
			f.write(v.content)
			f.close()
			print("Get ",fN)
		end
	end
end

local function checkFiles()
	local dat,rtn = {},{}
	for i=2,#tArgs do
		table.insert(dat,tArgs[i])
	end
	for i,v in ipairs(dat) do
		if not fs.exists(fs.combine(shell.dir(),v)) then
			error("FILE: "..v.." does not exists",0)
		end
		local f = fs.open(fs.combine(shell.dir(),v),"r")
		rtn[v] = f.readAll()
		f.close()
	end
	return rtn
end

local function putFiles()
	local snd = checkFiles()
		local req = http.post('https://api.github.com/gists',"files="..json.encode(snd).."&description="..'testnstuff'.."&public=true")
		local res = json.decode(req.readAll())
		req.close()
		print('ID: '..res.id)
end

if #tArgs <= 1 then
	printUsage()
elseif tArgs[1] == 'get' then
	print("Start download: "..tArgs[2])
	forkID(tArgs[2],toboolean(tArgs[4]),toboolean(tArgs[3]))
elseif tArgs[1] == 'put' then
	print("Dont work at moment sry!")
	--putFiles()
end
