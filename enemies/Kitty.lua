require "common/class"

Kitty = buildClass(Enemy)


function Kitty:_init()
  Enemy._init(self)
  
  self.velocity.max = {x = 2}
  
  self.animations.walking = Animation( "catanim" )
  
  self.animations.current = self.animations.walking
  
  self:setSize(32, 32)
  
  if math.random(2) == 1 then
    self:moveLeft()
  else
    self:moveRight()
  end
end

