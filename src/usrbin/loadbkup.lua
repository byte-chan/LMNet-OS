print("LoadBackup: Awaiting a blank floppy disk")
while true do
  local event, side = os.pullEvent()
  if event == "disk" then
    print("LoadBackup: Would you like to load: '"..os.getLabel(side).."' ? y/n")
    print("NOTE: This will erase all existing files")
    local input = read()
    if input == "y" then
      print("
    else
      print("LoadBackup: Operation Cancelled")
    end
  end
end
