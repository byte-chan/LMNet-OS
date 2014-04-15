-- API CONFIG
-- Change values in this part if needed.
-- include API version in packet
local includeAPIVersion = true

-- INTERNAL
local apiVersion = 1

-- FUNCTIONS
-- internal function makePacket: returns serialized content of 'data' argument
local function makePacket(data)
	return textutils.serialize(data)
end

-- send the content of 'data' to computer ID 'id'
function send(id, data)
	if includeAPIVersion then
		data.apiVersion = apiVersion
	end
	rednet.send(id, makePacket(data))
end

-- broadcast the content of 'data' to all computers
function broadcast(data)
	if includeAPIVersion then
		data.apiVersion = apiVersion
	end
	rednet.broadcast(makePacket(data))
end

-- receive packet, returns contents of packet
function receive(timeout)
	local id, msg = rednet.receive(timeout)
	if not id or not msg then
		return nil
	end
	local len = msg:len()
	local data
	if msg:sub(1, 1) == "{" and msg:sub(len, len) == "}" then
		data = textutils.unserialize(msg)
		if not data then
			data = {}
		end
	end
	if data.target then
		if data.target == os.getComputerID() then
			return id, data
		else
			return nil
		end
	end
	return id, data
end

-- 