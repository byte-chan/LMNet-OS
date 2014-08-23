local function request(pURL)
	pURL = table.concat(pURL, "/")
	local URL
	if pURL:sub(1,5) == "https" then
		URL = pURL
	else
		URL = 'https://api.github.com/'..pURL
	end
	--print('Get: '..URL)
	local res = http.get(URL)
	if res then
		return json.decode(res.readAll())
	else
		printError('No data!')
		return nil
	end
end

local function getRepoAsFile(owner,repo)
	--NOT FINISH NOW!--
	for i,v in pairs(content) do
		if v['type'] == 'file' then

		elseif v['type'] == 'dir' then
			getDir(owner,repo)
		end
	end
end

function getCommits(owner,repo)
	return request({'repos',owner,repo,'commits'})
end

function getSingleCommit(owner,repo,sha)
	return request({'repos',owner,repo,'commits',sha})
end

function getRepo(owner,repo, ... )
	local pluArgs = { ... }
	return request({'repos',owner,repo,unpack(pluArgs)})
end

function getUser(user,content)
	return request({'users',user,content})
end

function getRepoContent(user,repo,path)
	return getRepo(user,repo,'contents',path)
end

function gists(pID)
	return request({'gists',pID})
end

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