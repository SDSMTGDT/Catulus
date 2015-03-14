require "Secretary"
require "Player"
require "Block"
require "QuadTree"

player = Player()

function love.load( )
  print(player.__index)
  
  -- Starting position & gravity
  player:setPosition( 100 , 100 )
  player:setAcceleration( 0, 0.25 )
  player:setSize(32, 64)
  
  -- Build level
  for i=0, (512-32), 32 do
    Block(i, 512-32)
  end
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
