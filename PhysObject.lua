require "Secretary"

-- Required fluff for classes
PhysObject = {}
PhysObject.__index = PhysObject

-- Syntax is very weird in this section, but it's necessary for classes
setmetatable(PhysObject, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

---------------------------------------
-- BEGIN PhysObject CLASS DEFINITION --
---------------------------------------

--
-- Constructor
--
function PhysObject:_init( )
  -- Declare object properties
  self.id = nil
  self.visible = true
  self.size = {}
  self.position = {}
  self.velocity = {}
  self.acceleration = {}
  
  -- Initialize Size
  self.size.width = 0
  self.size.height = 0
  self.size.depth = 0
  
  -- Initialize location
  self.position.x = 0
  self.position.y = 0
  self.position.z = 0
  
  -- Initialize velocity
  self.velocity.x = 0
  self.velocity.y = 0
  self.velocity.z = 0
  
  -- Initialize acceleration
  self.acceleration.x = 0
  self.acceleration.y = 0
  self.acceleration.z = 0
  
  -- Register with object manager
  Secretary.registerObject(self)
  Secretary.registerEvent(self, EventType.PHYSICS, self.update)
  Secretary.registerEvent(self, EventType.DRAW, self.draw)
end

--
-- PhysObject:getInstanceId
--
function PhysObject:getInstanceId( )
  return self.id
end

--
-- PhysObject:setVisible
--
function PhysObject:setVisible( visible )
  self.visible = visible
end

--
-- PhysObject:isVisible
--
function PhysObject:isVisible()
  return self.visible
end
  
--
-- PhysObject:setSize
--
function PhysObject:setSize( w, h, d )
  -- Handle optional argument d
  d = d or self.size.depth
  
  -- Set size
  self.size.width = w
  self.size.height = h
  self.size.depth = d
end

--
-- PhysObject:getSize
--
function PhysObject:getSize()
  return self.size.width, self.size.height, self.size.depth
end

--
-- PhysObject
--
function PhysObject:getBoundingBox()
  return self.position.y, self.position.x + self.size.width,
    self.position.y + self.size.height, self.position.x,
    self.position.z, self.position.z + self.size.depth
end

--
-- PhysObject:setPosition
--
function PhysObject:setPosition( x, y, z )
  -- Handle optional argument z
  z = z or self.position.z
  
  -- Set coordinates
  self.position.x = x
  self.position.y = y
  self.position.z = z
end

--
-- PhysObject:getPosition
--
function PhysObject:getPosition( )
  return self.position.x, self.position.y, self.position.z
end

--
-- PhysObject:setVelocity
--
function PhysObject:setVelocity( x, y, z )
  -- Handle optional argument z
  z = z or self.velocity.z
  
  -- Set velocity vector
  self.velocity.x = x
  self.velocity.y = y
  self.velocity.z = z
end

--
-- PhysObject:getVelocity
--
function PhysObject:getVelocity( )
  return self.velocity.x, self.velocity.y, self.velocity.z
end

--
-- PhysObject:setAcceleration
--
function PhysObject:setAcceleration( x, y, z )
  -- Handle optional argument z
  z = z or self.acceleration.z
  
  -- Set acceleration vector
  self.acceleration.x = x
  self.acceleration.y = y
  self.acceleration.z = z
end

--
-- PhysObejct:getAcceleration
--
function PhysObject:getAcceleration( )
  return self.acceleration.x, self.acceleration.y, self.acceleration.z
end

--
-- PhysObject:update
--
function PhysObject:update( )
  -- Update velocity
  self.velocity.x = self.velocity.x + self.acceleration.x
  self.velocity.y = self.velocity.y + self.acceleration.y
  self.velocity.z = self.velocity.z + self.acceleration.z
  
  -- Update position
  self.position.x = self.position.x + self.velocity.x
  self.position.y = self.position.y + self.velocity.y
  self.position.z = self.position.z + self.velocity.z
end

--
-- PhysObject:draw
--
function PhysObject:draw( )
  -- Must be defined on a per-object basis
end

function PhysObject:collidesWith( t2, r2, b2, l2 )
  local t1, r1, b1, l1 = self:getBoundingBox()
  
  if b1 > t2 and t1 < b2 and r1 > l2 and l1 < r2 then
    return true
  else
    return false
  end
end
