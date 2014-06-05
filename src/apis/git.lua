function get(user, repo, bran, path, save)
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

function getFunc(user, repo, bran)
	if not user or not repo or not bran then
		error("not enough arguments, expected 3", 2)
	end
	return function(path, save)
		if not path then
			error("not enough arguments, expected 1 or 2", 2)
		end
		get(user, repo, bran, path, save)
	end
end