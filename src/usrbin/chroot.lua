local tArgs = {...}
if #tArgs < 1 then
	print("Usage: chroot <path>")
	return
end

local chrootPath = shell.resolve(tArgs[1])

local oldfs = {}
for k, v in pairs(fs) do
	oldfs[k] = v
end

fs.list = function(path)
	return oldfs.list(fs.combine(chrootPath, path))
end

fs.exists = function(path)
	return oldfs.exists(fs.combine(chrootPath, path))
end

fs.isDir = function(path)
	return oldfs.isDir(fs.combine(chrootPath, path))
end

fs.isReadOnly = function(path)
	return oldfs.isReadOnly(fs.combine(chrootPath, path))
end

fs.getName = oldfs.getName and function(path)
	return oldfs.getName(fs.combine(chrootPath, path))
end

fs.getSize = function(path)
	return oldfs.getSize(fs.combine(chrootPath, path))
end

fs.getDrive = function()
	return "chroot"
end

fs.getFreeSpace = function(path)
	return oldfs.getFreeSpace(fs.combine(chrootPath, path))
end

fs.makeDir = function(path)
	return oldfs.makeDir(fs.combine(chrootPath, path))
end

fs.move = function(path1, path2)
	return oldfs.move(path1, path2)
end

fs.copy = function(path1, path2)
	return oldfs.copy(path1, path2)
end

fs.delete = function(path)
	return oldfs.delete(path)
end

fs.combine = oldfs.combine

fs.open = function(path, mode)
	return oldfs.open(fs.combine(chrootPath, path), mode)
end

shell.run("bash")

fs = oldfs