require "Secretary"
require "LoveEvents"
require "Camera"
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
require "Bobbit"

room = nil
proptest = nil
pauseMenu = nil
rootSecretary = Secretary()
debugger = Debugger():registerWithSecretary(rootSecretary)
game = Game(rootSecretary)
camera = Camera()

bobtest = Bobbit(3, 100, 100)
bobtest:registerWithSecretary( rootSecretary )

function love.load( )
  
  -- Preload sprites
  local file = love.filesystem.newFile("preload_anim.txt", "r")
  for line in file:lines() do
    Animation.load(line)
  end
  file:close()
  
  camera:setDimensions(love.graphics.getWidth(), love.graphics.getHeight())
  camera:registerWithSecretary(rootSecretary)
  
  game:loadLevel("level1.txt")
  game:startGame()
  
  rootSecretary:registerEventListener({}, function(_, key, isrepeat)
      
      -- Display pause menu
      if key == "escape" then
        game:pause()
      end
    end, EventType.KEYBOARD_DOWN)
end