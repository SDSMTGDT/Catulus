require "PhysObject"

Segment = buildClass(PhysObject)


function Segment:_init( )



  self.extendFactor = 1
  self.swayFactor = 1
  self.extendCommand = true
  self.swayCommand = true
  self.extention = 0
  self.sway = 0
  self.image = nil

end

function Segment:registerWithSecretary( )

  PhysObject.registerWithSecretary(self, secretary)
  


end

function Segment:onStep( )

  --On step check for bullet collision
  
  
  
  --extend or retract based on extendFactor and command

  

  --sway based on sway factor sway command
  
  
  
end

function Segment:draw( )

  love.graphics.setColor( 255, 255, 255 )
  love.graphics.draw( )


end