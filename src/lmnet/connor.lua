os.derp = function()
  term.setTextColour(colours.pink)
  print("Herpy Derpy Durp")
  term.setTextColour(colours.white)
end

os.squid = function()
  local chance = math.random(1, 2)
  if chance == 1 then
    term.setTextColour(colours.blue)
    print("The Squid goes Splash")
    term.setTextColour(colours.white)
  else
    term.setTextColour(colours.grey)
    print("The Squid Inked on You!")
    term.setTextColour(colours.white)
  end
end

os.bro = function()
  if turtle then 
    if os.getComputerLabel() == "Broturtle" then
      term.setTextColour(colours.green)
      print("BROFIST! PWN3D!")
      term.setTextColour(colours.white)
    else
      error("YOU'RE NOT BROTURTLE D:", 0)
    end
  else
    error("Seriously? Broturtle is a Turtle.", 0)
  end
end
