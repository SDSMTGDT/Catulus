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
  
  Secretary.registerEvent(self, EventType.POST_PHYSICS, Player.onCollisionCheck)
  Secretary.registerEvent(self, EventType.STEP, Player.onStep)
  Secretary.registerEvent(self, EventType.KEYBOARD_DOWN, Player.onKeyPress)
end

function Player:onStep( )
  --Simple character movement on the x axis
  if love.keyboard.isDown( "a" ) then
    if self.velocity.x > -self.velocity.max.x then
      self.velocity.x = self.velocity.x - 0.375
    end
  end
  
  if love.keyboard.isDown( "d" ) then
    if self.velocity.x < self.velocity.max.x then
      self.velocity.x = self.velocity.x + 0.375
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
  love.graphics.draw(self.image, (x+32), (y-32), rotation, -1, 1)

  love.graphics.rectangle( "fill", x, y, 32, 64 )
end

function Player:onCollisionCheck( )
  local list = Secretary.getCollisions( self:getBoundingBox() )
  
  for i,o in pairs(list) do
    if self ~= o and instanceOf(o, Block) then
      if self:collidesWith(o:getBoundingBox()) then
        self.position.y = o.position.y - self.size.height
        self.velocity.y = 0
      end
    end
  end
  
  --Friction
  if self.velocity.y == 0 then
    if self.velocity.x > 0.125 then
      self.velocity.x = self.velocity.x - 0.125
    elseif self.velocity.x < -0.125 then
      self.velocity.x = self.velocity.x + 0.125
    else
      self.velocity.x = 0
    end
  end
  
end
