require "Secretary"
require "LoveEvents"
require "Player"
require "Block"
require "Enemy"
require "Animation"
require "LevelBuilder"
require "Button"
require "Menu"
require "Debugger"
require "Prop"

player = nil
room = nil
proptest = nil
enemies = {}
pauseMenu = nil
rootSecretary = Secretary()
gameSecretary = Secretary()
rootSecretary:registerChildSecretary(gameSecretary)
debugger = Debugger():registerWithSecretary(rootSecretary)

function love.load( )
  
  -- Preload sprites
  local file = love.filesystem.newFile("preload_anim.txt", "r")
  for line in file:lines() do
    Animation.load(line)
  end
  file:close()
  
  player = Player():registerWithSecretary(gameSecretary)
  proptest = Prop(50, 96, "fishidle", DrawLayer.MAIN):registerWithSecretary(gameSecretary)
  room = buildLevelFromFile("level1.txt")
  
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
        local enemy = Enemy():registerWithSecretary(gameSecretary)
        table.insert(enemies, enemy)
        enemy:setPosition(64, 64)
        if math.random(2) == 1 then
          enemy:moveLeft()
        else
          enemy:moveRight()
        end
      
      -- Clear enemies
      elseif key == "backspace" then
        clearEnemies()
      end
    end, EventType.KEYBOARD_DOWN)
end

function clearEnemies()
  for k,enemy in pairs(enemies) do
    enemy:destroy()
    enemies[k] = nil
  end
end
