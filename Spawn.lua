require "common/class"
require "PhysObject"

Spawn = buildClass()

function Spawn:_init(x, y, ...)
  self.x = x or 0
  self.y = y or 0
  self.enemyTypes = {...}
end