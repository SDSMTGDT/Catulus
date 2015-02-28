require "Player"
require "Block"
require "QuadTree"

player = Player()
blocks = {}
quadtree = QuadTree(1, 0, 512, 512, 0)

function love.load( )
  print(player.__index)
  
  -- Starting position & gravity
  player:setPosition( 100 , 100 )
  player:setAcceleration( 0, 0.25 )
  player:setSize(32, 64)
  
  -- Build level
  for i=0, (512-32) do
    table.insert(blocks, Block(i, 512-32))
  end
end

function love.update( dt )
  if dt < 1/60 then
    love.timer.sleep( 1/60 - dt )
  end
  
  player:update()
  
  --Sloppy collision checking
  for k,block in pairs(blocks) do
    if player:collidesWith(block:getBoundingBox()) then
      player.position.y = block.position.y - 64
      player.velocity.y = 0
    end
  end
  
  --Simple character movement on the x axis
  if love.keyboard.isDown( "a" ) then
    if player.velocity.x > -player.velocity.max.x then
      player.velocity.x = player.velocity.x - 0.375
    end
    
    if player.velocity.x < 0 then
      playerDirection = "left"
    end
  end
  
  if love.keyboard.isDown( "d" ) then
    if player.velocity.x < player.velocity.max.x then
      player.velocity.x = player.velocity.x + 0.375
    end
    
    if player.velocity.x > 0 then
      playerDirection = "right"
    end
  end
  
  
  --Friction
  if player.velocity.x > 0 and player.velocity.y == 0 then
  player.velocity.x = player.velocity.x - 0.125
  end
  
  if player.velocity.x < 0 and player.velocity.y == 0 then
  player.velocity.x = player.velocity.x + 0.125
  end
  
  love.graphics.print(love.timer.getFPS(), 0, 0)
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

function love.mousepressed( x, y, button )
  if button == "l" then
    local block = Block(x,y)
    block:setSize(8,8)
    table.insert(blocks, block)
    quadtree:insert(block)
  end
  
  if button == "r" then
    quadtree:clear()
   end
end

function love.draw( )
  
  quadtree:draw()

  --Draw in the platform
  for key,value in pairs(blocks) do
    value:draw()
  end
  
  player:draw( playerDirection )
end
