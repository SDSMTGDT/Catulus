require "common/class"
require "Animation"
require "Secretary"

Prop = buildClass( )

function Prop:_init( x, y, imgname, layer )

  layer = layer or DrawLayer.BACKGROUND_PROPS
  self.x = x
  self.y = y
  
  self.animation = Animation( imgname )

  gameSecretary:registerEventListener(self, self.onStep, EventType.STEP)
  gameSecretary:registerEventListener(self, self.draw, EventType.DRAW)
  gameSecretary:setDrawLayer(self, layer)
  
end

function Prop:onStep( )

  self.animation:update( )

end

function Prop:draw( )
  
  love.graphics.setColor(255, 255, 255)
  self.animation:draw(self.x , self.y, 0 )

end



