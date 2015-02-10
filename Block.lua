Block = {}
Block.__index = Block

setmetatable(Block, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

function Block:_init(x, y)
  self.position = {}
  self.position.x = x
  self.position.y = y
end

function Block:draw()
  love.graphics.setColor( 255, 255, 255 )
  love.graphics.rectangle( "fill", self.position.x, self.position.y, 32, 32 )
end
