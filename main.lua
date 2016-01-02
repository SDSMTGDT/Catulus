require "Secretary"
require "LoveEvents"
require "Player"
require "Block"
require "Enemy"
require "LevelBuilder"
require "Button"
require "Menu"

player = nil
room = nil
enemies = {}
pauseMenu = nil
rootSecretary = Secretary()
gameSecretary = Secretary()
rootSecretary:registerChildSecretary(gameSecretary)

function love.load( )
  player = Player()
  room = buildLevelFromFile("level1.txt")
  
  rootSecretary:registerEventListener(room, room.adjustCanvas, EventType.PRE_DRAW)
  rootSecretary:registerEventListener(room, room.onWindowResize, EventType.WINDOW_RESIZE)
  
  rootSecretary:registerEventListener({}, function(_, key, isrepeat)
      
      -- Display pause menu
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
        
      -- Spawn enemy
      elseif key == "return" then
        if gameSecretary.paused then return end
        local enemy = Enemy()
        table.insert(enemies, enemy)
        enemy:setPosition(64, 64)
        if math.random(2) == 1 then
          enemy:moveLeft()
        else
          enemy:moveRight()
        end

        print("Objects: " .. gameSecretary.tree:getSize())
      
      -- Clear enemies
      elseif key == "backspace" then
        clearEnemies()
      end
    end, EventType.KEYBOARD_DOWN)
end

function clearEnemies()
  for k,enemy in pairs(enemies) do
    gameSecretary:remove(enemy)
    enemies[k] = nil
  end
end
