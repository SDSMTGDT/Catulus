require "Player"

player = Player()

function love.load( )
  player:setPosition( 100 , 100 )
  player:setAcceleration( 0, 0.1 )
end

function love.draw( )
  player:draw()
end

function love.update( dt )
  if dt < 1/60 then
    love.timer.sleep( 1/60 - dt )
  end
  
  player:update()
  print(love.timer.getFPS())
end
