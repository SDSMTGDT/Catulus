
Player = {}

Player.__index = Player

setmetatable(Player,{
__call = function(cls, ...)
  return cls.new(...)
  end,
  })

function Player.new( )
  local self = setmetatable( {} , Player )
  self.velocityX = 0
  self.velocityY = 0
  self.accelerationX = 0
  self.accelerationY = 0
  self.x = 0 
  self.y = 0
  return self
end

function Player:setPosition( px , py )
  print (self)
  self.x = px
  self.y = py
end

function Player:getPostion()
  return self.x, self.y
end

function Player:setVelocity( x , y )
  self.velocityX = x
  self.velocityY = y
 end
 
function Player:getVelocity( )
  return self.velocityX, self.velocityY
end

function Player:setAcceleration( x , y )
  self.accelerationX = x
  self.accelerationY = y
end

function Player:getAcceleration( )
  return self.accelerationX, self.accelerationY
end

function Player:update(  )
  self.velocityX = self.velocityX + self.accelerationX
  self.velocityY = self.velocityY + self.accelerationY
   
  self.x = self.x + self.velocityX
  self.y = self.y + self.velocityY
end

function Player:draw( )
  
  love.graphics.setColor( 255, 255, 255 )
  love.graphics.rectangle( "fill", self.x, self.y, 20, 20 )
  
end
 

