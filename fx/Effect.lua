
Effect = buildClass(Prop)

function Effect:_init( noFrames, x, y, imgname, layer )

  Prop._init( self, x, y, imgname, layer )
  
  self.frameCount = noFrames
  
end

function Effect:registerWithSecretary(secretary)
  Prop.registerWithSecretary(self, secretary)  
  
  return self
end

function Effect:onStep( )
  if self.frameCount <= 0 then
    Prop:destroy( )
  else
    Prop:onStep( )
    self.frameCount = self.frameCount - 1
  end
  
end

function Effect:onDraw( )
  Prop:draw( )
end