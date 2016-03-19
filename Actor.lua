require "common/class"
require "PhysObject"
require "common/functions"

Actor = buildClass(PhysObject)

function Actor:_init( )
  PhysObject._init( self )
  self.horizontalStep = 0
  self.dieSoon = false
  
  self:setAcceleration( 0, 0.25 )
end

function Actor:registerWithSecretary(secretary)
  PhysObject.registerWithSecretary(self, secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.onPostPhysics, EventType.POST_PHYSICS)
  
  return self
end

function Actor:setHorizontalStep( s )
  assertType(s, "s", "number")
  self.horizontalStep = s
end

function Actor:getHorizontalStep( )
  return self.horizontalStep  
end

function Actor:die( reason )
  self:destroy()
end

function Actor:collisionWithWall(wall)
  -- Nothing else to do
end

function Actor:onPostPhysics( )
  if self.dieSoon then
    self:destroy()
    return
  end
  
  if self:getSecretary() == nil then
    return
  end
  
  -- Get own bounding box
  local t, r, b, l = self:getBoundingBox()
  local room = game.room
  
  -- Get block collisions
  local list = self:getSecretary():getCollisions( t, r, b, l, Block )
  
  for i,o in ipairs(list) do

    -- Store other's bounding box
    local t, r, b, l = o:getBoundingBox()

    -- Collision! Are we dropping down?
    if self.velocity.y > 0 then
      self.position.y = t - self.size.height
      self.velocity.y = 0

    -- Collision! Are we flying up?
    elseif self.velocity.y < 0 then
      self.position.y = b
      self.velocity.y = 0
    end
  end
  
  -- ****************************************************************************
  
  -- Get our bounding box again
  local speed = self.horizontalStep
  t, r, b, l = self:getBoundingBox(speed, 0, 0)
  
  -- Adjust step for screen wrapping
  if room ~= nil then
    if speed > 0 and l >= room.width then
      speed = 0 - self.position.x - self.size.width + speed
    elseif speed < 0 and r <= 0 then
      speed = room.width + self.size.width + (speed * 2)
    end
  end
  
  -- Make sure future location is clear
  local jump = true
  local block = nil
  list = self:getSecretary():getCollisions( t, r, b, l, Block )
  
  if list[1] ~= nil then
    -- We're going to collide with the environment; cancel movement
    jump = false
    block = list[1]
  end
  
  -- If future position is clear, make our move
  if jump == true then
    self.position.x = self.position.x+speed
  else
    self:collisionWithWall(block)
  end
  
end
