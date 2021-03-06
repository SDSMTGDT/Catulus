require "common/class"
require "PhysObject"

Bullet = buildClass(PhysObject)

function Bullet:_init( x, y, r, s )
  PhysObject._init( self )
  
  self:setPosition(x, y)
  self:setVelocity(math.cos(r) * s, math.sin(r) * s)
  self:setSize(4, 4)
  
  self.life = 30
end

function Bullet:registerWithSecretary(secretary)
  PhysObject.registerWithSecretary(self, secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.onPostPhysics, EventType.POST_PHYSICS)
  
  return self
end

function Bullet:actOn( other )
  if other == nil then
    return
  end
  
  if instanceOf(other, Block) then     -- WALL
    return
  elseif instanceOf(other, Enemy) then -- ENEMY
    other:die( self )
  end
end

function Bullet:die( reason )
  reason = reason or nil
  
  self.dieSoon = true
  if reason ~= nil then
    self.dieReason = reason
  end
end

function Bullet:onPostPhysics( )
  if self.dieSoon then
    self:actOn( self.dieReason )
    self:destroy()
    return
  end
  
  -- self-destruct if timer runs out
  if self.life <= 0 then
    self:die()
    return
  end
  
  -- self-destruct if collides with wall or enemy
  local t, r, b, l = self:getBoundingBox()
  local others = self:getSecretary():getCollisions( t, r, b, l, Enemy, SolidBlock )
  for _,other in ipairs(others) do
    if instanceOf(other, Block) then
      self:die()
      return
    elseif instanceOf(other, Enemy) then
      self:die( other )
      return
    end
  end
  
  -- grow older
  self.life = self.life - 1
end

function Bullet:draw( )
  love.graphics.setColor( 255, 0, 0 )
  
  local x, y = self:getPosition()
  local w, h = self:getSize()
  
  love.graphics.line(x + w/2, y + h/2, x + w/2 - 2 * self.velocity.x, y + h/2 - 2 * self.velocity.y)
  love.graphics.rectangle( "fill", x, y, w, h )
end
