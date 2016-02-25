require "Enemy"

Penguin = buildClass(Enemy)

function Penguin:_init( )


  self.anim = Animation( )

  self:setSize(32, 48)
end 

function Penguin:bounceLeft( )




end

function Penguin:bounceRight( )




end