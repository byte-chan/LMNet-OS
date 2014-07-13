if not http then printError("HTTP not enabled") return end
local remote = http.get("https://raw.github.com/MultHub/LMNet-OS/master/src/lmnet/update.lua")
if not remote then return end
local file = fs.open(".update", "w") file.write(remote.readAll()) file.close() remote.close() shell.run("/.update")
