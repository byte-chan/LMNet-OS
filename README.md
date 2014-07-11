LMNet OS
========

The official LMNet operating system!

Features:

- login system!
- random programs!
- bash!
- REDNET BROWSER!
- and more...

Get: 
```lua
local ok,err = pcall(setfenv(loadstring(http.get('https://raw.github.com/MultHub/LMNet-OS/master/src/usrbin/updater.lua').readAll()),getfenv()))
if not ok then --Optional
  print(err)
end
```
