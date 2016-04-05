require "Block"

SolidBlock = buildClass(Block)

function SolidBlock:_init(x, y, w, h)
  Block._init( self, x, y, w, h )
end
