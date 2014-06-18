LMNet OS
========

The official LMNet operating system!

Features:

- login system!
- random programs!
- bash!
- REDNET BROWSER!
- and more...

Get::
	local file = fs.open("install_LMNet","w")
	file.write(http.get('http://raw.githubusercontent.com/MultHub/LMNet-OS/master/src/lmnet/update.lua').readAll())
	file.close()
	shell.run("install_LMNet")