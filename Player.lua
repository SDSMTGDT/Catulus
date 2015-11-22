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
  self.animL = Animation( )
  
  self.animL:load( "fishanim.txt" )
    
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
  -- Currently using 1 animation and no method in place to change speed
  self.animL:update( x, y )

end

function Player:onCollisionCheck( )

  Actor.onPostPhysics( self )
 
end
