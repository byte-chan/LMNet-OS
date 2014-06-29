local function request(pURL)
	if type(pURL) == 'table' then
		local x = ''
		for i=1,#pURL do
			x = x..pURL[i]..'/'
		end
		pURL = x
	end
	local URL = textutils.urlEncode('https://api.github.com/'..pURL)
	if URL:sub(URL:len(),URL:len()) == "/" then
		URL = URL:sub(1,URL:len()-1)
	end
	local res = http.get(URL)
	if res then
		return json.decode(res.readAll())
	else
		return nil
	end
end

function getUser(user,content)
	return request({'users',user,content})
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