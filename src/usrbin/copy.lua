local tArgs = { ... }
if #tArgs < 2 then
	print( "Usage: cp <source> <destination>" )
	return
end

local source = tArgs[1]
if source:sub(1, 1) == "~" then
	source = "/"..(currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser))..source:sub(2)
end
local sSource = shell.resolve( source )
local dest = tArgs[2]
if dest:sub(1, 1) == "~" then
	dest = "/"..(currentUser == "root" and systemDirs.root or fs.combine(systemDirs.users, currentUser))..dest:sub(2)
end
local sDest = shell.resolve( dest )
if fs.find then
	local tFiles = fs.find( sSource )
	if #tFiles > 0 then
		for n,sFile in ipairs( tFiles ) do
			if fs.isDir( sDest ) then
				fs.copy( sFile, fs.combine( sDest, fs.getName(sFile) ) )
			elseif #tFiles == 1 then
				fs.copy( sFile, sDest )
			else
				printError( "Cannot overwrite file multiple times" )
				return
			end
		end
	else
		printError( "No matching files" )
	end
else
	if fs.exists(sDest) then
		printError("File exists")
	else
		fs.copy(sSource, sDest)
	end
end