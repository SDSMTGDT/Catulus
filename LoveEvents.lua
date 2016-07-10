require "Secretary"

function love.update( dt )
  
  -- Regulate the framerate to 60 fps
  local targetTime = love.timer.getTime() + (1/60 - dt)
  while love.timer.getTime() < targetTime do end
  
  -- Call step-based events
  rootSecretary:onPrePhysics()
  rootSecretary:onPhysics()
  rootSecretary:onPostPhysics()
  rootSecretary:onStep()
end

function love.resize( w, h )
  rootSecretary:onWindowResize(w, h)
end

function love.draw( )
  rootSecretary:onPreDraw()
  rootSecretary:onDraw()
end

function love.keypressed( key, scancode, isrepeat )
  rootSecretary:onKeyboardDown(key, scancode, isrepeat)
end

function love.keyreleased( key, scancode )
  rootSecretary:onKeyboardUp(key, scancode)
end

function love.mousepressed( x, y, button )
  rootSecretary:onMouseDown(x, y, button)
end

function love.mousereleased( x, y, button )
  rootSecretary:onMouseUp(x, y, button)
end

function love.mousemoved( x, y, dx, dy )
  rootSecretary:onMouseMove(x, y, dx, dy)
end

function love.wheelmoved( x, y )
  rootSecretary:onMouseWheelMove(x, y)
end

function love.joystickpressed( joystick, button )
  rootSecretary:onJoystickDown(joystick, button)
end

function love.joystickreleased( joystick, button )
  rootSecretary:onJoystickUp(joystick, button)
end

function love.joystickadded( joystick )
  rootSecretary:onJoystickAdded(joystick)
end

function love.joystickremoved( joystick )
  rootSecretary:onJoystickRemoved(joystick)
end
