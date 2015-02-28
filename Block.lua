require "PhysObject"

Block = {}
Block.__index = Block

setmetatable(Block, {
    __index = PhysObject,
    __metatable = PhysObject,
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

function Block:_init(x, y)
  PhysObject._init( self )
  self:setPosition(x, y)
  self:setSize(32, 32)
end

function Block:draw()
  love.graphics.setColor( 255, 255, 255 )
  love.graphics.rectangle( "fill", self.position.x, self.position.y, self.size.width, self.size.height )
end
