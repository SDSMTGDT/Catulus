require "common/class"
require "Animation"
require "Secretary"

Prop = buildClass( )

function Prop:_init( x, y, filename )

  self.x = x
  self.y = y
  
  self.animation = Animation( filename )

  gameSecretary:registerEventListener(self, self.onStep, EventType.STEP)
  gameSecretary:registerEventListener(self, self.draw, EventType.DRAW)
  gameSecretary:setDrawLayer(self, DrawLayer.BACKGROUND_PROPS)
  
end

function Prop:onStep( )

  self.animation:update( )

end

function Prop:draw( )

  self.animation:draw(self.x , self.y, 0 )

end



