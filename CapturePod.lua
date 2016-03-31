require "common/class"
require "Bullet"

CapturePod = buildClass(Bullet)


function CapturePod:_init( x, y, r, s, player )
  Bullet._init(self, x, y, r, s )
  
end


function CapturePod:actOn( other )
  if other == nil then
    return
  end
  
  Bullet.actOn(self, other)
  
  if instanceOf(other, Enemy) then -- ENEMY
    game.player:addKitten()
  end
end
  