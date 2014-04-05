local function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

local function requestObject(url,sN,mode)
		if not url then error('Incorrect statement!') end
		if not sN and mode == 'get' then error('Check mode!') end
		if mode == 'get' then
			http.request(url)
			local requesting = true
			while requesting do
				local event, url, sourceText = os.pullEvent()
				if event == "http_success" then
					local respondedText = sourceText.readAll()
					temp = io.open(sN,'w')
					temp:write(respondedText)
					temp:close()
					requesting = false
					return true
				elseif event == "http_failure" then
					requesting = false
					return false
				end
			end
		elseif mode == 'view' then
			write('Fetching: '..url..'... ')
			http.request(url)
			local requesting = true
			while requesting do
				local event, url, sourceText = os.pullEvent()
				if event == "http_success" then
					local respondedText = sourceText.readAll()
					temp = io.open('temp','w')
					temp:write(respondedText)
					temp:close()
					edit('temp')
					fs.delete('temp')
					requesting = false
					return true
				elseif event == "http_failure" then
					requesting = false
					return false
				end
			end
		end
end

local function compileURL(auth,pro,bran,pat)
    baseURL = 'https://raw.github.com/'..auth..'/'..pro..'/'..bran..'/'..pat
    return baseURL
end

local function get(auth,reps,bran,paths,sN)
    if not auth or not reps or not bran or not paths or not sN then error('Attempt to compile nonexistent terms!') end
    statusCode = requestObject(compileURL(auth,reps,bran,paths),sN,'get')
    return statusCode
end

local function getFile(file, target)
	write(file.." -> "..target..": ")
	local ret = get("MultHub", "LMNet-OS", "master", file, target)
	if ret == false then
		print("error.")
	else
		print("OK.")
	end
end

getFile("version.txt", ".updaterVersionCheck")
local remoteFile = fs.open(".updaterVersionCheck", "r")
local remoteVersion = tonumber(remoteFile.readAll())
remoteFile.close()
local localFile = fs.open(".lmnetVersion", "r")
local localVersion = tonumber(localFile.readAll())
localFile.close()

clear()

local tArgs = {...}

if remoteVersion <= localVersion and tArgs[1] ~= "--force" then
	print("Running the latest version of LMNet OS.")
	print("Run this program again with --force to reinstall LMNet OS.")
	return
end

clear()

print("LMNet OS - update or install")
print("Getting files...")
getFile("src/startup.lua", "startup")
getFile("src/lmnet/init.lua", ".lmnet/init")
getFile("src/lmnet/update.lua", ".lmnet/update")
getFile("src/usrbin/bash.lua", "usr/bin/bash")
getFile("src/usrbin/cat.lua", "usr/bin/cat")
getFile("src/usrbin/echo.lua", "usr/bin/echo")
getFile("src/usrbin/startw.lua", "usr/bin/startw")
print("Press any key to continue")
while true do
	local e = os.pullEvent("key")
	if e == "key" then break end
	sleep(0)
end
os.reboot()
