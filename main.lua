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


function verifyVersion()
  
  -- Ensure function even exists (doesn't exist for older versions of Love2D)
  if love.getVersion == nil then
    return false
  end
  
  local major, minor, revision, codename = love.getVersion()
  if major < 0 or (major == 0 and minor < 10) then
    return false
  end
end


function love.load( )
  
  if verifyVersion() == false then
    love.window.showMessageBox( "Update Love2D", "You are running an older version of Love2D. Update to version 10.0 or later" )
    love.event.quit()
    return
  end
  
  
  -- Preload sprites
  local file = love.filesystem.newFile("preload_anim.txt", "r")
  for line in file:lines() do
    Animation.load(line)
  end
  file:close()
  
  camera:setDimensions(love.graphics.getWidth(), love.graphics.getHeight())
  camera:registerWithSecretary(rootSecretary)
  
  game:startLevel("level1")
  game:mainMenu()
  
  rootSecretary:registerEventListener({}, function(_, key, scancode, isrepeat)
      
      -- Display pause menu
      if key == "escape" then
        game:pause()
      end
    end, EventType.KEYBOARD_DOWN)
end