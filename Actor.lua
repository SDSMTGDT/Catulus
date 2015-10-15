require "PhysObject"

Actor = {}
Actor.__index = Actor

setmetatable(Actor, {
    __index = PhysObject,
    __metatable = PhysObject,
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

function Actor:_init( )
  PhysObject._init( self )
  self.horizontalStep = 0
  self.dieSoon = false
  
  self:setAcceleration( 0, 0.25 )
  
  Secretary.registerEvent(self, EventType.POST_PHYSICS, self.onPostPhysics)
end

function Actor:setHorizontalStep( s )
  assert( type(s) == "number", "Argument must be number!!!!" )
  self.horizontalStep = s
end

function Actor:getHorizontalStep( )
  return self.horizontalStep  
end

function Actor:die( reason )
  Secretary.remove( self )
end

function Actor:onPostPhysics( )
  if self.dieSoon then
    Secretary.remove( self )
    return
  end
  
  local list = Secretary.getCollisions( self:getBoundingBox() )
  
  for i,o in pairs(list) do
    if self ~= o and instanceOf(o, Block) and self:collidesWith(o:getBoundingBox()) then
      
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
  end
  -- ****************************************************************************
  
  -- Get our bounding box
  local t, r, b, l = self:getBoundingBox()
  local speed = self.horizontalStep
  
  -- Make sure future location is clear
  local jump = true
  list = Secretary.getCollisions( t, r+speed, b, l+speed )
  
  for i,o in pairs(list) do
    if self ~= o and instanceOf(o, Block) and o:collidesWith(t, r+speed, b, l+speed) then
        
        -- We're going to collide with the environment; cancel movement
      jump = false
      break
    end
  end
    -- If future position is clear, make our move
  if jump == true then
      self.position.x = self.position.x+speed
  end
  
end
