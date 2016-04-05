require "Block"

PassthroughBlock = buildClass(Block)

function PassthroughBlock:_init(x, y, w, h)
  Block._init(self, x, y, w, h)
end

function PassthroughBlock:draw()
  Block.draw(self)
  love.graphics.setColor( 200, 200, 200 )
  love.graphics.polygon( "fill", self.position.x, self.position.y, self.position.x + self.size.width, self.position.y, self.position.x + self.size.width / 2, self.position.y + self.size.height )
end