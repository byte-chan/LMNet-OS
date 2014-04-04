if not http then
	if os.getenv then
		if os.getenv("OS") == "Windows_NT" then
			os.execute("cls")
		end
	else
		clear()
	end
	print("HTTP connection required to update. Enable the HTTP API or do a manual install.")
	if not git then
		print("And install the git API.")
	end
	if not fs or not term or not shell then
		print("AND STOP PLAYING ON YOUR LOCAL MACHINE AND GET A LIFE AND CRAFTOS!")
		print("Achievement get!")
		print("Pro Debugger")
		print("I'm too busy writing these messages.")
		print("Ask Luca for support.")
	end
	return
end

print("Looking for update...")
if tonumber(git.get("MultHub/LMNet-OS/ver.txt")) <= tonumber(file.readAll()) then
	print("Running the latest version.")
	return
end