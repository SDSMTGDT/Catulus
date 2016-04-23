levelScript["level1"] = function()
  --Room dimensions
  width = 48
  height = 36
  
  
  --Initilize room
  local room = Room(width, height)
  
  local menu = Menu(game.secretary, "Main Menu", 0, 0, game.room.width, game.room.height):registerWithSecretary(rootSecretary)