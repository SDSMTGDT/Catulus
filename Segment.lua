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
  self.holdPeriod = 32*segId
  self.frequency = math.pi * (1/((segNum)*16))
  self.extending = true
  self.holding = false
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
    if self.currOffset >= self.maxExtend then
	  self.extending = false
	end
	
	  local x = self.origin[1]+math.floor( 10*math.sin(self.frequency*self.currOffset) )
      local y = self.origin[2]-self.currOffset
	  
      --print( math.floor(math.sin(self.frequency*self.currOffset)))
      --print( self.currOffset)
      self:setPosition( x, y )
  elseif self.extending == false then    
      self.currOffset =self.currOffset-1
    if self.currOffset <= self.maxRetract then
	    self.extending = true
	end
	
	  local x = self.origin[1]+math.floor( 10*math.sin(-self.frequency*self.currOffset) )	  
      local y = self.origin[2]-self.currOffset
		
      --print( math.floor(math.sin(self.frequency*self.currOffset)))
      --print( self.currOffset)
      self:setPosition( x, y )
  end
    


end

function Segment:draw( )

 local x, y = self:getPosition( )
   --print( "Hello World".. " ".. x )
 love.graphics.setColor( 255, 255, 255 )
 self.animation:draw(x, y)

end