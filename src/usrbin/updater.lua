local function clear()
	term.clear()
	term.setCursorPos(1, 1)
end

local function requestObject(url,sN,mode)
		if not url then error('Incorrect statement!') end
		if not sN and mode == 'get' then error('Check mode!') end
		if mode == 'get' then
			http.request(url)
			local requesting = true
			while requesting do
				local event, url, sourceText = os.pullEvent()
				if event == "http_success" then
					local respondedText = sourceText.readAll()
					temp = io.open(sN,'w')
					temp:write(respondedText)
					temp:close()
					requesting = false
					return true
				elseif event == "http_failure" then
					requesting = false
					return false
				end
			end
		elseif mode == 'view' then
			write('Fetching: '..url..'... ')
			http.request(url)
			local requesting = true
			while requesting do
				local event, url, sourceText = os.pullEvent()
				if event == "http_success" then
					local respondedText = sourceText.readAll()
					temp = io.open('temp','w')
					temp:write(respondedText)
					temp:close()
					edit('temp')
					fs.delete('temp')
					requesting = false
					return true
				elseif event == "http_failure" then
					requesting = false
					return false
				end
			end
		end
end

local function compileURL(auth,pro,bran,pat)
    baseURL = 'https://raw.github.com/'..auth..'/'..pro..'/'..bran..'/'..pat
    return baseURL
end

local function get(auth,reps,bran,paths,sN)
    if not auth or not reps or not bran or not paths or not sN then
        error('Attempt to compile nonexistent terms!')
    end
    statusCode = requestObject(compileURL(auth,reps,bran,paths),sN,'get')
    return statusCode
end

local function getFile(file, target)
	write(file.." -> "..target..": ")
	local ret = get("MultHub", "LMNet-OS", "master", file, target)
	if ret == false then
		print("error.")
		return false
	else
		print("OK.")
		return true
	end
end

if not http then
	print("HTTP API not enabled.")
	return
end

local ok = getFile("src/lmnet/update.lua", "/.update")
if not ok then
	return
end

shell.run("/.update")