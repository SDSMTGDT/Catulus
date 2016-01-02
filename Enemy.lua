require "Actor"
require "Animation"

Enemy = {}
Enemy.__index = Enemy

setmetatable(Enemy, {
    __index = Actor,
    __metatable = Actor,
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

function Enemy:_init( )
  Actor._init( self )
  self.velocity.max = {x = 2}
  
  self.anim = Animation( "catanim" )
  
  self:setSize(32, 32)
  gameSecretary:registerEventListener(self, self.onStep, EventType.STEP)
end

function Enemy:moveLeft()
  self:setHorizontalStep(-self.velocity.max.x)
end

function Enemy:moveRight()
  self:setHorizontalStep(self.velocity.max.x)
end

function Enemy:stopMoving()
  self:setHorizontalStep(0)
end

function Enemy:onStep()
  local speed = self:getHorizontalStep()
  local t, r, b, l = self:getBoundingBox()
  local list = gameSecretary:getCollisions( t, r+speed, b, l+speed )
  
  for i,o in pairs(list) do
    if o ~= self and instanceOf(o, Block) and o:collidesWith(t, r+speed, b, l+speed) then
      self:setHorizontalStep(-speed)
      break
    end
  end
  
  self.anim:update( )
  
end

function Enemy:draw()
--  love.graphics.setColor( 255, 0, 0 )
  local x, y = self:getPosition()
--  local w, h = self:getSize()
--  love.graphics.rectangle( "fill", x, y, w, h )
  
  love.graphics.setColor(255, 255, 255)
  self.anim:draw( x , y )
  
end
