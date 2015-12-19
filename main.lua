require "Secretary"
require "LoveEvents"
require "Player"
require "Block"
require "Enemy"
require "LevelBuilder"

player = Player()
room = nil
enemies = {}

function love.load( )
  room = buildLevelFromFile("level1.txt")
  
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
