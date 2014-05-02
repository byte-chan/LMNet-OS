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

shell.setDir("")

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
getFile("src/usrbin/userctl.lua", "usr/bin/userctl")
getFile("src/usrbin/loader.lua", "usr/bin/loader")
getFile("src/usrbin/lmlua.lua", "usr/bin/lmlua")
getFile("src/usrbin/rdnt.lua", "usr/bin/rdnt")
getFile("src/usrbin/rdnt-srv.lua", "usr/bin/rdnt-srv")
getFile("src/usrbin/cd.lua", "usr/bin/cd")
getFile("src/usrbin/copy.lua", "usr/bin/copy")
getFile("src/usrbin/move.lua", "usr/bin/move")
getFile("src/usrbin/list.lua", "usr/bin/list")
getFile("src/usrbin/mkdir.lua", "usr/bin/mkdir")
getFile("src/usrbin/delete.lua", "usr/bin/delete")
getFile("src/usrbin/pwd.lua", "usr/bin/pwd")
getFile("src/usrbin/makerbot.lua", "usr/bin/makerbot")
getFile("src/usrbin/updater.lua", "usr/bin/updater")
getFile("src/usrbin/remotecl.lua", "usr/bin/remotecl")
getFile("src/usrbin/remotesv.lua", "usr/bin/remotesv")
getFile("src/apis/git.lua", ".lmnet/apis/git")
getFile("src/apis/packet.lua", ".lmnet/apis/packet")
getFile("src/apis/config.lua", ".lmnet/apis/config")
getFile("src/apis/ui.lua", ".lmnet/apis/ui")
getFile("src/lmnet/login.lua", ".lmnet/login")
print("Creating missing directories...")
if not fs.exists("root") then
	fs.makeDir("root")
end
if not fs.exists("home") then
	fs.makeDir("home")
end
if not fs.exists(".lmnet/apis/http") then
	fs.makeDir(".lmnet/apis/http")
end
if not fs.exists(".lmnet/apis/turtle") then
	fs.makeDir(".lmnet/apis/turtle")
end
print("Press any key to continue")
while true do
	local e = os.pullEvent("key")
	if e == "key" then break end
	sleep(0)
end
os.reboot()