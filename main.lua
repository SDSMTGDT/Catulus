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
require "Game"

room = nil
proptest = nil
pauseMenu = nil
rootSecretary = Secretary()
debugger = Debugger():registerWithSecretary(rootSecretary)
game = Game(rootSecretary)

function love.load( )
  
  -- Preload sprites
  local file = love.filesystem.newFile("preload_anim.txt", "r")
  for line in file:lines() do
    Animation.load(line)
  end
  file:close()
  
  game:loadLevel("level1.txt")
  game:startGame()
  
  rootSecretary:registerEventListener({}, function(_, key, isrepeat)
      
      -- Display pause menu
      if key == "escape" then
        game:setPaused(game:isPaused() == false)
      elseif key == "return" then
        if game:isPaused() == false then
          local e = Enemy():registerWithSecretary(game.secretary)
          local p = game.room.enemySpawnPoints[math.random(table.getn(game.room.enemySpawnPoints))]
          e:setPosition(p.x, p.y)
          if math.random(2) == 1 then
            e:moveLeft()
          else
            e:moveRight()
          end
        end
      end
    end, EventType.KEYBOARD_DOWN)
end