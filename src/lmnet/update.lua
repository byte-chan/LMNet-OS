local function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

local function get(user, repo, bran, path, save)
	if not user or not repo or not bran or not path then
		error("not enough arguments, expected 4 or 5", 2)
	end
    local url = "https://raw.github.com/"..user.."/"..repo.."/"..bran.."/"..path
	local remote = http.get(url)
	if not remote then
		return false
	end
	local text = remote.readAll()
	remote.close()
	if save then
		local file = fs.open(save, "w")
		file.write(text)
		file.close()
		return true
	end
	return text
end

local function getFile(file, target)
	return get("MultHub", "LMNet-OS", "master", file, target)
end

shell.setDir("")

clear()

print("LMNet OS - update or install")
print("Getting files...")
local files = {
	["src/startup.lua"] = "startup",
	["src/lmnet/init.lua"] = ".lmnet/init",
	["src/lmnet/login.lua"] = ".lmnet/login",
	["src/lmnet/update.lua"] = ".lmnet/update",
	["src/usrbin/bash.lua"] = "usr/bin/bash",
	["src/usrbin/cat.lua"] = "usr/bin/cat",
	["src/usrbin/cd.lua"] = "usr/bin/cd",
	["src/usrbin/copy.lua"] = "usr/bin/copy",
	["src/usrbin/delete.lua"] = "usr/bin/delete",
	["src/usrbin/echo.lua"] = "usr/bin/echo",
	["src/usrbin/fileman.lua"] = "usr/bin/fileman",
	["src/usrbin/git.lua"] = "usr/bin/git",
	["src/usrbin/list.lua"] = "usr/bin/list",
	["src/usrbin/lmlua.lua"] = "usr/bin/lmlua",
	["src/usrbin/loader.lua"] = "usr/bin/loader",
	["src/usrbin/makerbot.lua"] = "usr/bin/makerbot",
	["src/usrbin/mkdir.lua"] = "usr/bin/mkdir",
	["src/usrbin/move.lua"] = "usr/bin/move",
	["src/usrbin/netget.lua"] = "usr/bin/netget",
	["src/usrbin/netsend.lua"] = "usr/bin/netsend",
	["src/usrbin/peripherals.lua"] = "usr/bin/peripherals",
	["src/usrbin/pwd.lua"] = "usr/bin/pwd",
	["src/usrbin/rdnt.lua"] = "usr/bin/rdnt",
	["src/usrbin/rdnt-srv.lua"] = "usr/bin/rdnt-srv",
	["src/usrbin/remotecl.lua"] = "usr/bin/remotecl",
	["src/usrbin/remotesv.lua"] = "usr/bin/remotesv",
	["src/usrbin/startw.lua"] = "usr/bin/startw",
	["src/usrbin/updater.lua"] = "usr/bin/updater",
	["src/usrbin/userctl.lua"] = "usr/bin/userctl",
	["src/apis/config.lua"] = ".lmnet/apis/config",
	["src/apis/git.lua"] = ".lmnet/apis/git",
	["src/apis/packet.lua"] = ".lmnet/apis/packet",
	["src/apis/ui.lua"] = ".lmnet/apis/ui",
}
local fileCount = 0
for _ in pairs(files) do
	fileCount = fileCount + 1
end
local filesDownloaded = 0
for k, v in pairs(files) do
	term.setTextColor(colors.black)
	term.setBackgroundColor(colors.white)
	clear()
	term.setCursorPos(2, 2)
	print("LMNet OS Updater")
	term.setCursorPos(2, 4)
	print("File: "..v)
	local w, h = term.getSize()
	term.setCursorPos(2, h - 1)
	print(tostring(math.floor(filesDownloaded / fileCount * 100)).."% - "..tostring(filesDownloaded + 1).."/"..tostring(fileCount))
	local ok = getFile(k, v)
	if not ok then
		if term.isColor() then
			term.setTextColor(colors.red)
		end
		term.setCursorPos(2, 6)
		print("Error.")
		sleep(1)
	end
	filesDownloaded = filesDownloaded + 1
end
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
clear()
print("Creating missing directories...")
local dirs = {
	"root",
	"home",
	".lmnet/apis/http",
	".lmnet/apis/turtle",
}
for _, v in pairs(dirs) do
	if not fs.exists(v) then
		fs.makeDir(v)
	end
end
print("Press any key to continue")
os.pullEvent("key")
os.reboot()