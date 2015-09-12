require "Secretary"
require "Player"
require "Block"
require "Enemy"
require "QuadTree"

player = Player()

function love.load( )
  print(player.__index)
  
  -- Starting position & gravity
  player:setPosition( 100 , 100 )
  
  -- Build level
  for i=0, (512-32-32), 32 do
    Block(i, 0)
    Block(512-32, i)
    Block(512-32-i, 512-32)
    Block(0, 512-32-i)
  end
  Block(256, 256)
end

function love.draw( )
  Secretary.onDraw()
end

function love.update( dt )
  
  -- Regulate the framerate
  if dt < 1/60 then
    love.timer.sleep( 1/60 - dt )
  end
  
  -- Call step-based events
  Secretary.onPrePhysics()
  Secretary.onPhysics()
  Secretary.onPostPhysics()
  Secretary.onStep()
  
  love.graphics.print(love.timer.getFPS(), 0, 0)
end

function love.keypressed( key, isrepeat )
  Secretary.onKeyboardDown(key, isrepeat)
  
  --Escape
  if key == "escape" then
    love.event.quit()
  elseif key == "return" then
    local enemy = Enemy()
    enemy:setPosition(64, 64)
    if math.random(2) == 1 then
      enemy:moveLeft()
    else
      enemy:moveRight()
    end
    
    print("Objects: " .. Secretary.tree:getSize() .. "\n")
  end
end

function love.keyreleased( key )
  Secretary.onKeyboardUp(key)
end

function love.mousepressed( x, y, button )
  Secretary.onMouseDown(x, y, button)
end

function love.mousereleased( x, y, button )
  Secretary.onMouseUp(x, y, button)
end

function love.mousemoved( x, y, dx, dy )
  Secretary.onMouseMove(x, y, dx, dy)
end

function love.joystickpressed( joystick, button )
  Secretary.onJoystickDown(joystick, button)
end

function love.joystickreleased( joystick, button )
  Secretary.onJoystickUp(joystick, button)
end

function love.joystickadded( joystick )
  Secretary.onJoystickAdded(joystick)
end

function love.joystickremoved( joystick )
  Secretary.onJoystickRemoved(joystick)
end
