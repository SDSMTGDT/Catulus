
require "PhysObject"
require "Segment"

Bobbit = buildClass(PhysObject)


function Bobbit:_init( segNum, x, y )

  PhysObject._init(self)

  self.segments = {}
  self.animation = Animation("bobidle")
  self.segmentCount = segNum
  self.origin = {x, y}
  
  --extension and retraction maxes must encompass a full period in the sin wave for 
  --smooth movement of the entity
  self.maxExtend = 32*segNum
  self.maxRetract = 0
  self.currOffset = 0
  self.amplitude = 10
  self.frequency = math.pi * (1/(segNum*16))
  self.extending = true
  
  self:setPosition( x, y )
  
  for i = 1, segNum do
    self.segments[i] = Segment( i, segNum, x, y+(2*i) )
  end
  --print( "Hello World".. " ".. x )

end


function Bobbit:registerWithSecretary( secretary )

  PhysObject.registerWithSecretary(self, secretary)
  
  for i = 1, self.segmentCount do
    self.segments[i]:registerWithSecretary(secretary)
  end
    
  secretary:registerEventListener( self, self.draw, EventType.DRAW )
  secretary:registerEventListener( self, self.onStep, EventType.STEP )

end

function Bobbit:onStep( )

  if self.extending == true then
    self.currOffset = self.currOffset+1
  else
    self.currOffset = self.currOffset-1
  end
  
  if self.currOffset >= self.maxExtend then
	self.extending = false
  elseif self.currOffset <= self.maxRetract then
    self.extending = true
  end
	
  local x = self.origin[1]+self.amplitude*math.sin(self.frequency*self.currOffset) 
  local y = self.origin[2]-self.currOffset

  self:setPosition( x, y )
  self.animation:update( )


end

function Bobbit:draw( )

 local x, y = self:getPosition( )
   --print( "Hello World".. " ".. x )
 love.graphics.setColor( 255, 255, 255 )
 self.animation:draw(x, y)

end