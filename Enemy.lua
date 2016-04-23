require "common/class"
require "Actor"
require "Animation"

Enemy = buildClass(Actor)

function Enemy:_init( )
  Actor._init( self )
  
  self.velocity.max = {x = 2}
  self.animations = {}
  self.animations.current = {}
end

function Enemy:registerWithSecretary(secretary)
  Actor.registerWithSecretary(self, secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.onStep, EventType.STEP)
  
  return self
end

function Enemy:onStep()
  self.animations.current:update()
end

function Enemy:draw()
  local x, y = self:getPosition()
  
  love.graphics.setColor(255, 255, 255)
  --self.animations.current:draw( x , y )
  self.animations.current:draw( x+self.size.width/2, y, self.size.width/2 )
end

function Enemy:moveLeft()
  self:setHorizontalStep(-self.velocity.max.x)
end

function Enemy:moveRight()
  self:setHorizontalStep(self.velocity.max.x)
end

function Enemy:die( reason )
  sound:play(sound.sounds.stomp)
  Actor.die(self, reason)
end

function Enemy:collisionWithWall(wall)
  Actor.collisionWithWall(self, wall)
  self:setHorizontalStep(-self:getHorizontalStep())
end

function Enemy:stopMoving()
  self:setHorizontalStep(0)
end

require "enemies/Kitty"
require "enemies/Penguin"