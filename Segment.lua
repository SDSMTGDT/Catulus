require "PhysObject"

Segment = buildClass(PhysObject)


function Segment:_init( segId, segNum, x, y )

  PhysObject._init(self)

  self.animation = Animation("catanim")
  self.segmentNumber = segId
  self.origin = {x, y}
  
  --extension and retraction maxes must encompass a full period in the sin wave for 
  --smooth movement of the entity
  self.maxExtend = 32*segNum - 32*segId
  self.maxRetract = -32*segId
  self.currOffset = -32*segId
  self.amplitude = 10
  self.frequency = math.pi * (1/((segNum)*16))
  self.extending = true
  self:setPosition( x, y )
  
  --print( "Hello World".. " ".. x )

end


function Segment:registerWithSecretary( secretary )

  PhysObject.registerWithSecretary(self, secretary)
    
  secretary:registerEventListener( self, self.draw, EventType.DRAW )
  secretary:registerEventListener( self, self.onStep, EventType.STEP )

end

function Segment:onStep( )
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
end

function Segment:draw( )

 local x, y = self:getPosition( )
   --print( "Hello World".. " ".. x )
 love.graphics.setColor( 255, 255, 255 )
 if self.currOffset >= self.segmentNumber then
  self.animation:draw(x, y)
 end

end