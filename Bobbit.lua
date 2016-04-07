
require "PhysObject"

Bobbit = buildClass(PhysObject)


function Bobbit:_init( segNum )

  PhysObject._init(self)

  self.segments = {}
  self.animation = Animation()
  self.segmentCount = segNum
  self.swayDistance = 10
  self.extensionDistance = 32
  
  for i = 1, self.segmentCount do
    self.segments[i] = Segment( )
	self.segments[i].swayFactor = i
  end
end


function Bobbit:registerWithSecretary( )

  PhysObject.registerWithSecretary(self, secretary)
  
  
  
  secretary:registerEventListener( self, self.draw, EventType.DRAW )
  secretary:registerEventListener( self, self.dictate, EvenType.STEP )

end


function Bobbit:dictate( )


  --issue commands to all the segments
  for i = 1, self.segmentCount do
    if math.abs(self.segments[i].extension) > self.extensionDistance then
      self.segments[i].extendCommand = ~self.segments[i].extendCommand
	end
	
	if math.abs(self.segments[i].sway) > self.swayDistance then
	  self.segments[i].swayCommand = ~self.segments[i].swayCommand
	end	
  end


end


function Bobbit:draw( )

 love.graphics.setColor( 255, 255, 255 )
 self.animation:draw( )

end