require "common/class"
require "PhysObject"

Actor = buildClass(PhysObject)

function Actor:_init( )
  PhysObject._init( self )
  self.horizontalStep = 0
  self.dieSoon = false
  
  self:setAcceleration( 0, 0.25 )
  
  gameSecretary:registerEventListener(self, self.onPostPhysics, EventType.POST_PHYSICS)
end

function Actor:setHorizontalStep( s )
  assert( type(s) == "number", "Argument must be number!!!!" )
  self.horizontalStep = s
end

function Actor:getHorizontalStep( )
  return self.horizontalStep  
end

function Actor:die( reason )
  gameSecretary:remove( self )
end

function Actor:onPostPhysics( )
  if self.dieSoon then
    gameSecretary:remove( self )
    return
  end
  
  -- Get own bounding box
  local t, r, b, l = self:getBoundingBox()
  
  -- Get block collisions
  local list = gameSecretary:getCollisions( t, r, b, l, Block )
  
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
    if speed > 0 and l + speed >= room.width then
      speed = 0 - self.position.x - self.size.width + speed
    elseif speed < 0 and r + speed <= 0 then
      speed = room.width + self.size.width + (speed * 2)
    end
  end
  
  -- Make sure future location is clear
  local jump = true
  list = gameSecretary:getCollisions( t, r, b, l, Block )
  
  if table.getn(list) > 0 then
    -- We're going to collide with the environment; cancel movement
    jump = false
  end
    -- If future position is clear, make our move
  if jump == true then
      self.position.x = self.position.x+speed
  end
  
end
