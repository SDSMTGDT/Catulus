require "Secretary"
require "LoveEvents"
require "Player"
require "Block"
require "Enemy"
require "Animation"
require "LevelBuilder"
require "Button"
require "Menu"

player = nil
room = nil
enemies = {}
pauseMenu = nil

function love.load( )
  
  -- Preload sprites
  local file = love.filesystem.newFile("preload_anim.txt", "r")
  for line in file:lines() do
    Animation.load(line)
  end
  file:close()
  
  player = Player()
  room = buildLevelFromFile("level1.txt")
  
  Secretary.registerEventListener(room, room.adjustCanvas, EventType.PRE_DRAW)
  Secretary.registerEventListener(room, room.onWindowResize, EventType.WINDOW_RESIZE)
  
  Secretary.registerEventListener({}, function(_, key, isrepeat)
    --Escape
    if key == "escape" then
      if pauseMenu == nil then
        pauseMenu = Menu.createPauseMenu()
        
        local destroy = pauseMenu.destroy
        pauseMenu.destroy = function(self)
          pauseMenu = nil
          destroy(self)
        end
      else
        pauseMenu:destroy()
        pauseMenu = nil
      end
    elseif key == "return" then
      local enemy = Enemy()
      table.insert(enemies, enemy)
      enemy:setPosition(64, 64)
      if math.random(2) == 1 then
        enemy:moveLeft()
      else
        enemy:moveRight()
      end

      print("Objects: "..Secretary.tree:getSize())
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
