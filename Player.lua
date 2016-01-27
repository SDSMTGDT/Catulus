require "common/class"
require "Actor"
require "Animation"
require "Enemy"
require "Block"
require "Bullet"

Player = buildClass(Actor)



function Player:_init( )
  Actor._init( self )
  
  self.velocity.max = {x = 4, y = -1}
  self:setSize(32, 48)
  self.facing = "left"
  
  self.animations = {}
  self.animations.walk = Animation( "fishanim" )
  self.animations.idle = Animation( "fishidle" )
  self.animations.idle.rate = 6
  self.animations.fall = Animation( "fishfall" )
  self.animations.rise = Animation( "fishrise" )
  self.animations.current = self.animations.idle
  
  gameSecretary:registerEventListener(self, self.onCollisionCheck, EventType.POST_PHYSICS)
  gameSecretary:registerEventListener(self, self.onStep, EventType.STEP)
  gameSecretary:registerEventListener(self, self.onKeyPress, EventType.KEYBOARD_DOWN)
  gameSecretary:setDrawLayer(self, DrawLayer.SPOTLIGHT)
  
end



function Player:onStep( )
  
  if love.keyboard.isDown( "a" ) and love.keyboard.isDown( "d" ) == false then
    self:setHorizontalStep( -self.velocity.max.x )
    self.facing = "left"
  elseif love.keyboard.isDown( "d" ) and love.keyboard.isDown( "a" ) == false then
    self:setHorizontalStep( self.velocity.max.x )
    self.facing = "right"
  else
    self:setHorizontalStep( 0 )
  end
  
  local t, r, b, l = self:getBoundingBox(0, 1)
  local list = gameSecretary:getCollisions(t, r, b, l, Block)
  local midair = (table.getn(list) == 0)
  
  -- Set sprite state
  if midair and self.velocity.y <= 0 then
    self.animations.current = self.animations.rise
  elseif midair then
    self.animations.current = self.animations.fall
  elseif self.horizontalStep ~= 0 then
    self.animations.current = self.animations.walk
  else
	self.animations.current = self.animations.idle
  end
  
  -- Set sprite direction
  if self.facing == "right" then
    self.animations.current.xScale = -1
  elseif self.facing == "left" then
    self.animations.current.xScale = 1
  end
  
  self.animations.current:update()
end



function Player:onKeyPress( key, isrepeat )
  --Jump
  if key == " " then
    
    local ground = false
    local t, r, b, l = self:getBoundingBox(0, 1, 0)
    local others = gameSecretary:getCollisions( t, r, b, l, Block )
    
    if table.getn(others) > 0 then
      ground = true
    end
    
    if ground then
      self.velocity.y = self.velocity.y - 10
    end
  end
  
  -- Shoot
  if key == "j" then
    if self.facing == "left" then
      Bullet( self.position.x, self.position.y + self.size.height/2, 0, -32 )
    elseif self.facing == "right" then
      Bullet( self.position.x + self.size.width, self.position.y + self.size.height/2, 0, 32 )
    end
  end
end



function Player:draw( )
  local x, y = self:getPosition( )
  
  -- Draw selected animation
  love.graphics.setColor(255, 255, 255)
  self.animations.current:draw( x+self.size.width/2, y, self.size.width/2 )
end



function Player:onCollisionCheck( )
  local t, r, b, l = self:getBoundingBox( )
  local others = gameSecretary:getCollisions( t, r, b, l, Enemy )
  for _, other in ipairs(others) do
    
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
