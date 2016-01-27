require "common/class"
require "PhysObject"

Block = buildClass(PhysObject)

function Block:_init(x, y, w, h)
  PhysObject._init( self )
  self:setPosition(x, y)
  self:setSize(w or 32, h or 32)
end

function Block:draw()
  love.graphics.setColor( 255, 255, 255 )
  love.graphics.rectangle( "fill", self.position.x, self.position.y, self.size.width, self.size.height )
end
