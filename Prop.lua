require "common/class"
require "Animation"
require "Secretary"

Prop = buildClass(Entity)

function Prop:_init( x, y, imgname, layer )
  Entity._init(self)

  self.layer = layer or DrawLayer.BACKGROUND_PROPS
  self.x = x
  self.y = y
  
  self.animation = Animation( imgname )
  
end

function Prop:registerWithSecretary(secretary)
  Entity.registerWithSecretary(self, secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.onStep, EventType.STEP)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
  secretary:setDrawLayer(self, self.layer)
  
  return self
end

function Prop:onStep( )

  self.animation:update( )

end

function Prop:draw( )
  
  love.graphics.setColor(255, 255, 255)
  self.animation:draw(self.x , self.y, 0 )

end



