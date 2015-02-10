require "PhysObject"

Player = {}
Player.__index = Player

setmetatable(Player, {
    __index = PhysObject,
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

function Player:_init( )
  PhysObject._init( self )
end

function Player:draw( )
  local x, y = self:getPosition( )
  love.graphics.setColor( 255, 255, 255 )
  love.graphics.rectangle( "fill", x, y, 20, 20 )
end
 

