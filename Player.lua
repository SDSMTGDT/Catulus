require "Actor"
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
  self.image = love.graphics.newImage("gfx/character.png")
  self:setSize(32, 48)
  
  Secretary.registerEventListener(self, self.onCollisionCheck, EventType.POST_PHYSICS)
  Secretary.registerEventListener(self, self.onStep, EventType.STEP)
  Secretary.registerEventListener(self, self.onKeyPress, EventType.KEYBOARD_DOWN)
  
end

function Player:onStep( )
  
  if love.keyboard.isDown( "a" ) and love.keyboard.isDown( "d" ) == false then
    self:setHorizontalStep( -self.velocity.max.x )
  elseif love.keyboard.isDown( "d" ) and love.keyboard.isDown( "a" ) == false then
    self:setHorizontalStep( self.velocity.max.x )
  else
    self:setHorizontalStep( 0 )
  end
  
end

function Player:onKeyPress( key, isrepeat )
  --Jump
  if key == " " then
    
    local ground = false
    local others = Secretary.getCollisions( self:getBoundingBox( 0, 1, 0 ) )
    
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
    local bullet = Bullet( self.position.x, self.position.y, 0, 16 )
  end
end


function Player:draw( )
  local x, y = self:getPosition( )
  love.graphics.setColor( 255, 255, 255 )
  
  -- animate
  love.graphics.draw(self.image, (x+32), y, rotation, -1, 1)

  love.graphics.rectangle( "fill", x, y+32, 32, 16 )
end

function Player:onCollisionCheck( )
  
  local t, r, b, l = self:getBoundingBox( )
  local others = Secretary.getCollisions( t, r, b, l )
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
        Secretary.remove( other )
      end
    end
  end
  
  Actor.onPostPhysics( self )
  
end
