require "Player"
require "Block"

player = Player()
blocks = {}

function love.load( )
  -- Starting position & gravity
  player:setPosition( 100 , 100 )
  player:setAcceleration( 0, 0.25 )
  
  -- Build level
  for i=0, (512-32) do
    table.insert(blocks, Block(i, 512-32))
  end
end

function love.update( dt )
  if dt < 1/60 then
    love.timer.sleep( 1/60 - dt )
  end
  
  --Sloppy collision checking
  for k,block in pairs(blocks) do
    local px, py = player:getPosition()
    
    if px <= block.position.x + 32 and px + 32 >= block.position.x then
      if py + player.velocity.y + 64 >= block.position.y and py + player.velocity.y <= block.position.y + 32 then
        player.position.y = block.position.y - 64
        player.velocity.y = 0
      end
    end
  end
  
  --Simple character movement on the x axis
  if love.keyboard.isDown( "a" ) then
    player.position.x = player.position.x - 4
    playerDirection = "left"
  end
  
  if love.keyboard.isDown( "d" ) then
    player.position.x = player.position.x + 4
    playerDirection = "right"
  end
  
  player:update()
  print(love.timer.getFPS())
end

function love.keypressed( key, isrepeat )
  
  --Jump
  if key == " " then
    player.velocity.y = -8
    playerDirection = "jump"
  end
  
  --Escape
  if key == "escape" then
    love.event.quit()
  end

end

function love.draw( )

  --Draw in the platform
  for key,value in pairs(blocks) do
    value:draw()
  end
  
  player:draw( playerDirection )
end
