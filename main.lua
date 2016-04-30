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
require "Sound"


room = nil
proptest = nil
pauseMenu = nil
rootSecretary = Secretary()
debugger = Debugger():registerWithSecretary(rootSecretary)
game = Game(rootSecretary)
camera = Camera()
sound = Sound()

--Entry point of the game
function love.load( )
  
  -- Preload sprites
  local file = love.filesystem.newFile("preload_anim.txt", "r")
  for line in file:lines() do
    Animation.load(line)
  end
  file:close()
  
  --Initialize the camera object
  camera:setDimensions(love.graphics.getWidth(), love.graphics.getHeight())
  camera:registerWithSecretary(rootSecretary)
  
  --Begin the game and launch the main menu
  game:startLevel("level1")
  game:mainMenu()
  
  --Register an event trigger for the pause menu
  rootSecretary:registerEventListener({}, function(_, key, isrepeat)
      
      -- Display pause menu
      if key == "escape" then
        game:pause()
      end
    end, EventType.KEYBOARD_DOWN)
end