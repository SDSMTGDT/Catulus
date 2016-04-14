require "common/class"

Penguin = buildClass(Enemy)

function Penguin:_init( )
  Enemy._init(self)
  
  self.animations.waddle = Animation("penguinanim")
  self.animations.waddle.rate = 10
  self.animations.fall = Animation("penguinfall")
  self.animations.fall.rate = 5
  self.animations.current = self.animations.waddle

  self:setSize(32, 48)
  self.jumpTimer = 10
  self.direction = nil
  
  self.jumpConstant = 6
  self.jumpTimerMax = 120
  self.jumpTimer = 0
  
  self:moveRight()
end 

function Penguin:jump()
  if self.velocity.y == 0 then
    self.velocity.y = -self.jumpConstant
  end
end

function Penguin:moveRight()
  Enemy.moveRight(self)
  self.direction = "right"
end

function Penguin:moveLeft()
  Enemy.moveLeft(self)
  self.direction = "left"
end

function Penguin:collisionWithWall(wall)
  if self.direction == "left" then
    self:moveRight()
  else
    self:moveLeft()
  end
end

function Penguin:onStep()
  if self.velocity.y > 0 then
    self.animations.current = self.animations.fall
  else
    self.animations.current = self.animations.waddle
  end
  
  if self.direction == "right" then
    self.animations.current.xScale = -1
  else
    self.animations.current.xScale = 1
  end
    
  Enemy.onStep(self)
  
  
  if self.jumpTimer == 0 then
    self:jump()
    self.jumpTimer = self.jumpTimerMax
  end
  
  self.jumpTimer = self.jumpTimer - 1
end
  