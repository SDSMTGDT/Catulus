require "Actor"
require "Animation"
require "Enemy"
require "Block"
require "Bullet"

Player = {}
Player.__index = Player

setmetatable(Player, {
    __index = Actor,
    __metatable = Actor,
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

function Player:_init( )
  Actor._init( self )
  
  self.velocity.max = {x = 4, y = -1}
  self:setSize(32, 48)
  self.animPointer = 1
  
  self.animations = {}
  self.animations[1] = Animation( "fishanim" )
  self.animations[2] = Animation( "fishidle" )
  self.animations[3] = Animation( "fishjump" )
  
  gameSecretary:registerEventListener(self, self.onCollisionCheck, EventType.POST_PHYSICS)
  gameSecretary:registerEventListener(self, self.onStep, EventType.STEP)
  gameSecretary:registerEventListener(self, self.onKeyPress, EventType.KEYBOARD_DOWN)
  gameSecretary:setDrawLayer(self, DrawLayer.SPOTLIGHT)
  
end

function Player:onStep( )
  
  if love.keyboard.isDown( "a" ) and love.keyboard.isDown( "d" ) == false then
    self:setHorizontalStep( -self.velocity.max.x )
  elseif love.keyboard.isDown( "d" ) and love.keyboard.isDown( "a" ) == false then
    self:setHorizontalStep( self.velocity.max.x )
  else
    self:setHorizontalStep( 0 )
  end
  
  if self.horizontalStep > 0 then
    self.animPointer = 1
	self.animations[1].xScale = -1
	self.animations[2].xScale = -1
	self.animations[3].xScale = -1
  elseif self.horizontalStep < 0 then
    self.animPointer = 1
	self.animations[1].xScale = 1
	self.animations[2].xScale = 1
	self.animations[3].xScale = 1
  elseif self.velocity.y ~= 0 then
	self.animPointer = 3
  else
	self.animPointer = 2
  end
  
  self.animations[self.animPointer]:update( )
  
end

function Player:onKeyPress( key, isrepeat )
  --Jump
  if key == " " then
    
    local ground = false
    local others = gameSecretary:getCollisions( self:getBoundingBox( 0, 1, 0 ) )
    
    for _, other in pairs(others) do
      if instanceOf(other, Block) then
        ground = true
        break
      end
    end
    
    if ground then
      self.velocity.y = self.velocity.y - 10
    end
  end
  
  -- Shoot
  if key == "j" then
    if self.animations[self.animPointer].xScale > 0 then
      Bullet( self.position.x, self.position.y + self.size.height/2, 0, -16 )
    elseif self.animations[self.animPointer].xScale < 0 then
      Bullet( self.position.x + self.size.width, self.position.y + self.size.height/2, 0, 16 )
    end
  end
end


function Player:draw( )
  local x, y = self:getPosition( )
  
  -- Draw selected animation
  love.graphics.setColor(255, 255, 255)
  self.animations[self.animPointer]:draw( x+self.size.width/2, y, self.size.width/2 )
end

function Player:onCollisionCheck( )
  
  local t, r, b, l = self:getBoundingBox( )
  local others = gameSecretary:getCollisions( t, r, b, l )
  for _, other in pairs(others) do
    
    -- Check for collision with enemy
    if instanceOf(other, Enemy) then
      
      -- Test for goomba stomp
      if self.velocity.y > other.velocity.y and b < other.position.y + other.size.height then
        
        -- Bounce off enemy's head, jump higher if user is holding down jump button
        self:setPosition( self.position.x, other.position.y - self.size.height, self.position.z )
        if love.keyboard.isDown( " " ) then
          self:setVelocity( self.velocity.x, other.velocity.y - 8, self.velocity.z )
        else
          self:setVelocity( self.velocity.x, other.velocity.y - 4, self.velocity.z )
        end
        
        -- Destroy the enemy
        gameSecretary:remove( other )
      end
    end
  end
  
  Actor.onPostPhysics( self )
end
