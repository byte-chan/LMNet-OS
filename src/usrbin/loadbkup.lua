print("LoadBackup: Awaiting a blank floppy disk")
while true do
  local event, side = os.pullEvent()
  if event == "disk" then
    print("LoadBackup: Would you like to load: '"..os.getLabel(side).."' ? y/n")
    print("NOTE: This will erase all existing files")
    local input = read()
    if input == "y" then
      local files = fs.list("/")
      for i = 1, #files do
        fs.delete(files[i])
        print("LoadBackup: Deleted "..files[i])
      end
        local files = fs.list("/disk/")
        for i = 1, #files do
          fs.copy("/disk/"..files[i], "/"..files[i])
          print("LoadBackup: Restored "..files[i])
        end
      return
    else
      print("LoadBackup: Operation Cancelled")
      return
    end
  end
end
