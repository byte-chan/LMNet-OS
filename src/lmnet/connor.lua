os.derp = function()
  term.setTextColour(colours.pink)
  print("Herpy Derpy Durp")
  term.setTextColour(colours.white)
end

os.squid = function()
  local chance = math.random(1, 3)
  if chance == 3 then
    term.setTextColour(colours.blue)
    print("The Squid goes Splash 
    term.setTextColour(colours.white)
  else
    term.setTextColour(colours.grey)
    print("The Squid Inked on You!")
    term.setTextColour(colours.white)
  end
end
