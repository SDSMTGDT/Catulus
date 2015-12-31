require "Secretary"

function love.update( dt )
  -- Regulate the framerate to 60 fps
  local targetTime = love.timer.getTime() + (1/60 - dt)
  while love.timer.getTime() < targetTime do end
  
  -- Call step-based events
  Secretary.onPrePhysics()
  Secretary.onPhysics()
  Secretary.onPostPhysics()
  Secretary.onStep()
end

function love.resize( w, h )
  Secretary.onWindowResize(w, h)
end

function love.draw( )
  Secretary.onPreDraw()
  Secretary.onDraw()
end

function love.keypressed( key, isrepeat )
  Secretary.onKeyboardDown(key, isrepeat)
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
