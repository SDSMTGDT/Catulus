require "Secretary"
require "LoveEvents"
require "Player"
require "Block"
require "Enemy"
require "LevelBuilder"
require "Button"

player = Player()
room = nil
enemies = {}

function love.load( )
  room = buildLevelFromFile("level1.txt")
  
  local button1 = Button( "Level1", 32, 32, 128, 32 )
  button1:setOnClickAction(function()
    clearEnemies()
    for _,obj in pairs(room.objects) do
      Secretary.remove(obj)
    end
    Secretary.remove(room)
    room = buildLevelFromFile("level1.txt")
  end)
  
  local button2 = Button( "Level2", 32, 80, 128, 32 )
  button2:setOnClickAction(function()
    clearEnemies()
    for _,obj in pairs(room.objects) do
      Secretary.remove(obj)
    end
    Secretary.remove(room)
    room = buildLevelFromFile("level2.txt")
  end)
  
  
  Secretary.registerEventListener(room, room.adjustCanvas, EventType.PRE_DRAW)
  Secretary.registerEventListener(room, room.onWindowResize, EventType.WINDOW_RESIZE)
  
  Secretary.registerEventListener({}, function(_, key, isrepeat)
    --Escape
    if key == "escape" then
      love.event.quit()
    elseif key == "return" then
      local enemy = Enemy()
      table.insert(enemies, enemy)
      enemy:setPosition(64, 64)
      if math.random(2) == 1 then
        enemy:moveLeft()
      else
        enemy:moveRight()
      end

      print("Objects: " .. Secretary.tree:getSize() .. "\n")
    elseif key == "backspace" then
      clearEnemies()
    end
  end, EventType.KEYBOARD_DOWN)
end

function clearEnemies()
  for k,enemy in pairs(enemies) do
    Secretary.remove(enemy)
    enemies[k] = nil
  end
end
