require "Actor"
require "Animation"

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
  self.animations[1] = Animation( )
  self.animations[2] = Animation( )
  self.animations[3] = Animation( )
  
  self.animations[1]:load( "fishanim.txt" )
  self.animations[2]:load( "fishanim.txt" )
  
  self.animations[1].xScale = -1
  
  Secretary.registerEvent(self, EventType.POST_PHYSICS, self.onCollisionCheck)
  Secretary.registerEvent(self, EventType.STEP, self.onStep)
  Secretary.registerEvent(self, EventType.KEYBOARD_DOWN, self.onKeyPress)
  
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
  elseif self.horizontalStep < 0 then
    self.animPointer = 2
  end
  
  self.animations[self.animPointer]:update( )
  
end

function Player:onKeyPress( key, isrepeat )
  --Jump
  if key == " " then
    self.velocity.y = -8
  end
end


function Player:draw( )
  local x, y = self:getPosition( )
  
  -- animate 
  self.animations[self.animPointer]:draw( x+self.size.width/2, y, self.size.width/2 )
  
end

function Player:onCollisionCheck( )

  Actor.onPostPhysics( self )
 
end
