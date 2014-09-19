print("Time Machine: Awaiting a blank floppy disk")
while true do
  local event, side = os.pullEvent()
  if event == "disk" and fs.getFreeSpace("/disk/") > fs.getFreeSpace("/") then
    local files = fs.list("/")
    for i = 1, #files do
      if files[i] ~= "disk" then
       pcall(fs.copy, "/"..files[i], "/disk/"..files[i])
      end
  end
    local file = fs.open("/disk/.trigger", "w")
    file.write("Time Machine Trigger")
    file.close()
    disk.setLabel(side, "TM Backup: "..textutils.formatTime(os.time(), false).." Day: "..os.day())
    print("Time Machine: Completed backup")
    return
  end
end
