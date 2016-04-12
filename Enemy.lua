require "common/class"
require "Actor"
require "Animation"

Enemy = buildClass(Actor)

function Enemy:_init( )
  Actor._init( self )
  self.velocity.max = {x = 2}
  
  self.anim = Animation( "catanim" )
  
  self:setSize(32, 32)
  
  if math.random(2) == 1 then
    self:moveLeft()
  else
    self:moveRight()
  end
end

function Enemy:registerWithSecretary(secretary)
  Actor.registerWithSecretary(self, secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.onStep, EventType.STEP)
  
  return self
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
  self.anim:update()
end

function Enemy:collisionWithWall(wall)
  Actor.collisionWithWall(self, wall)
  self:setHorizontalStep(-self:getHorizontalStep())
end

function Enemy:draw()
  local x, y = self:getPosition()
  
  love.graphics.setColor(255, 255, 255)
  self.anim:draw( x , y )
end

function Enemy:die( reason )
  sound:play(sound.sounds.stomp)
  Actor.die(self, reason)
end