
require "PhysObject"

Bobbit = buildClass(PhysObject)


function Bobbit:_init( segNum )

  PhysObject._init(self)

  self.segments = {}
  self.animation = Animation()
  self.segmentCount = segNum
  self.origPosx = self.get
  self.maxExtend = nil
  self.maxRetract = nil
  
  for i = 1, self.segmentCount do
    self.segments[i] = Segment( )
  end
end


function Bobbit:registerWithSecretary( )

  PhysObject.registerWithSecretary(self, secretary)
  
  
  
  secretary:registerEventListener( self, self.draw, EventType.DRAW )
  secretary:registerEventListener( self, self.onStep, EvenType.STEP )

end

function Bobbit:onStep( )

  


end

function Bobbit:draw( )

 love.graphics.setColor( 255, 255, 255 )
 self.animation:draw( )

end