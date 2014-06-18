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
local file = fs.open("install_LMNet","w")
file.write(http.get('https://raw.githubusercontent.com/MultHub/LMNet-OS/master/src/lmnet/update.lua').readAll())
file.close()
shell.run("install_LMNet")
```
