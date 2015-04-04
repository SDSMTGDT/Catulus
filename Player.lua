require "PhysObject"

Player = {}
Player.__index = Player

setmetatable(Player, {
    __index = PhysObject,
    __metatable = PhysObject,
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

function Player:_init( )
  PhysObject._init( self )
  self.velocity.max = {x = 4, y = -1}
  self.image = love.graphics.newImage("gfx/character.png")
  self:setSize(32, 96)
  
  Secretary.registerEvent(self, EventType.POST_PHYSICS, Player.onCollisionCheck)
  Secretary.registerEvent(self, EventType.STEP, Player.onStep)
  Secretary.registerEvent(self, EventType.KEYBOARD_DOWN, Player.onKeyPress)
end

function Player:onStep( )
  
  -- Get our bounding box
  local t, r, b, l = self:getBoundingBox()
  local speed = self.velocity.max.x
  
  --Simple character movement on the x axis
  if love.keyboard.isDown( "a" ) then
    
    -- Make sure future location is clear
    local jump = true
    local list = Secretary.getCollisions( t, r-speed, b, l-speed )
    for i,o in pairs(list) do
      if self ~= o and instanceOf(o, Block) and o:collidesWith(t, r-speed, b, l-speed) then
        
        -- We're going to collide with the environment; cancel movement
        jump = false
        break
      end
    end
    
    -- If future position is clear, make our move
    if jump == true then
      self.position.x = self.position.x-speed
    end
    
  end
  
  if love.keyboard.isDown( "d" ) then
    
    -- Make sure future location is clear
    local jump = true
    local list = Secretary.getCollisions( t, r+speed, b, l+speed )
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
end

function Player:onKeyPress( key, isrepeat )
  --Jump
  if key == " " then
    self.velocity.y = -8
  end
end

function Player:draw( )
  local x, y = self:getPosition( )
  love.graphics.setColor( 255, 255, 255 )
  
  -- animate
  love.graphics.draw(self.image, (x+32), y, rotation, -1, 1)

  love.graphics.rectangle( "fill", x, y+32, 32, 64 )
end

function Player:onCollisionCheck( )
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
end
