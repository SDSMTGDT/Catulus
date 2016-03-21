require "common/class"
require "Actor"
require "Animation"
require "Enemy"
require "Block"
require "Bullet"

Player = buildClass(Actor)



function Player:_init( )
  Actor._init( self )
  
  self.velocity.max = {x = 4, y = -1}
  self:setSize(32, 48)
  self.facing = "left"
  
  self.animations = {}
  self.animations.walk = Animation( "fishanim" )
  self.animations.idle = Animation( "fishidle" )
  self.animations.idle.rate = 6
  self.animations.fall = Animation( "fishfall" )
  self.animations.rise = Animation( "fishrise" )
  self.animations.current = self.animations.idle
  
  self.heart = love.graphics.newImage("gfx/Heart.png")
  self.noHeart = love.graphics.newImage("gfx/Heart_empty.png")
  
  self.lifeMax   = 3
  self.lifeTotal = self.lifeMax
  self.invincibilityTimer = 0
  self.stuntimer = 0
  
  self.jumpTime = 1.0
  self.jumpMaxTime = 1.0
  self.jumpDecay = .1
  self.jumpConstant = .65
  self.goombaJump = 0
  
  self.sounds = {}
end

function Player:registerWithSecretary(secretary)
  Actor.registerWithSecretary(self, secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.onCollisionCheck, EventType.POST_PHYSICS)
  secretary:registerEventListener(self, self.onStep, EventType.STEP)
  secretary:registerEventListener(self, self.onKeyPress, EventType.KEYBOARD_DOWN)
  secretary:setDrawLayer(self, DrawLayer.SPOTLIGHT)
  
  return self
end



function Player:onStep( )
  
  if self.stuntimer == 0 then
    if love.keyboard.isDown( "a" ) and love.keyboard.isDown( "d" ) == false then
      self:setHorizontalStep( -self.velocity.max.x )
      self.facing = "left"
    elseif love.keyboard.isDown( "d" ) and love.keyboard.isDown( "a" ) == false then
      self:setHorizontalStep( self.velocity.max.x )
      self.facing = "right"
    else
      self:setHorizontalStep( 0 )
    end
	
	
	-- Jump Logic
	
	local ground = false
	local t, r, b, l = self:getBoundingBox(0, 1, 0)
	local others = self:getSecretary():getCollisions( t, r, b, l, Block )
		
	if table.getn(others) > 0 then
	  ground = true
	end
	
	if self.goombaJump == 1 and self.velocity.y >= -1 then
	  self.goombaJump = 0
	elseif self.goombaJump == 1 then
	  self.jumpTime = self.jumpMaxTime * 0.55
	end
	
	if self.jumpTime > 0 and love.keyboard.isDown(" ") and (ground == true or self.velocity.y < 0 or self.goombaJump == 1) then
	  if self.goombaJump == self.jumpMaxTime then
		self.goombaJump = 0
	  end
		self.velocity.y = self.velocity.y - self.jumpConstant * ((self.jumpTime + self.jumpMaxTime) / self.jumpMaxTime)
		self.jumpTime = self.jumpTime - self.jumpDecay
	else
	  self.jumpTime = 0
	end
	
	if ground == true and self.velocity.y == 0 then
	  self.goombaJump = 0
	  self.jumpTime = self.jumpMaxTime
	end
	
	
	if self.velocity.y > 0 then
		
	
	end
  end
  
  local t, r, b, l = self:getBoundingBox(0, 1)
  local list = self:getSecretary():getCollisions(t, r, b, l, Block)
  local midair = (table.getn(list) == 0)
  
  -- Set sprite state
  if midair and self.velocity.y <= 0 then
    self.animations.current = self.animations.rise
  elseif midair then
    self.animations.current = self.animations.fall
  elseif self.horizontalStep ~= 0 then
    self.animations.current = self.animations.walk
  else
	self.animations.current = self.animations.idle
  end
  
  -- Set sprite direction
  if self.facing == "right" then
    self.animations.current.xScale = -1
  elseif self.facing == "left" then
    self.animations.current.xScale = 1
  end
  
  -- Decrement Invincibility time if > 0
  if self.invincibilityTimer > 0 then
    self.invincibilityTimer = self.invincibilityTimer - 1
  end
  
  -- Check stuntimer if >0 decrement, otherwise set x velocity back to 0
  if self.stuntimer > 0 then
    self.stuntimer = self.stuntimer - 1
  else
    self:setVelocity( 0, self.velocity.y )
  end
  
  self.animations.current:update()
end



function Player:onKeyPress( key, isrepeat )
  --Jump
  --if key == " " and self.stuntimer == 0 then
  --  
  --  local ground = false
  --  local t, r, b, l = self:getBoundingBox(0, 1, 0)
  --  local others = self:getSecretary():getCollisions( t, r, b, l, Block )
  --  
  --  if table.getn(others) > 0 then
  --    ground = true
  --  end
  --  
  --  if ground then
  --    self.velocity.y = self.velocity.y - 10
  --  end
  --end
  
    -- Shoot
  if key == "j" and self.stuntimer ==0 then
    if self.facing == "left" then
      Bullet( self.position.x, self.position.y + self.size.height/2, 0, -32 ):registerWithSecretary(self:getSecretary())
    elseif self.facing == "right" then
      Bullet( self.position.x + self.size.width, self.position.y + self.size.height/2, 0, 32 ):registerWithSecretary(self:getSecretary())
    end
  end
end



function Player:draw( )
  local x, y = self:getPosition( )
  
  -- Draw selected animation
  love.graphics.setColor(255, 255, 255)
  if self.invincibilityTimer % 4 == 0 then
    self.animations.current:draw( x+self.size.width/2, y, self.size.width/2 )
  end
  
  -- Draw hearts
  for i = 1,self.lifeMax do
    if( i <= self.lifeTotal ) then
      --draw full heart at location 
	  love.graphics.draw(self.heart, 36*i, 32 + camera.offset.y)
    else
      --draw empty heart at location
	  love.graphics.draw(self.noHeart, 36*i, 32 + camera.offset.y)
    end
  end	
end



function Player:onCollisionCheck( )
  local stomped = false
  local t, r, b, l = self:getBoundingBox( )
  local others = self:getSecretary():getCollisions( t, r, b, l, Enemy )
  for _, other in ipairs(others) do
    
    -- Test for goomba stomp
    if self.velocity.y > other.velocity.y and b < other.position.y + other.size.height then

	  stomped = true
	  self.goombaJump = 1
      -- Bounce off enemy's head, jump higher if user is holding down jump button
      self:setPosition( self.position.x, other.position.y - self.size.height, self.position.z )
      self:setVelocity( self.velocity.x, other.velocity.y - 4, self.velocity.z )

      -- Destroy the enemy
      other:die()
	end
	
	-- If not goomba stomp and not invincible decrement life and set timer
	if self.invincibilityTimer == 0 and stomped == false then
	  self.lifeTotal = self.lifeTotal - 1
	  self.invincibilityTimer = 120
	  self.stuntimer = 30
	  self:setPosition( self.position.x, self.position.y-1 )
	  if self.lifeTotal > 0 then
		sound:play(sound.sounds.playerDamage)
	  else
		self:die()
	  end
	  --check relative location of the enemy
	  if other.position.x > self.position.x then
	    self:setVelocity( 0, -4 )
        self:setHorizontalStep(-3)
	  else
	    self:setVelocity( 0, -4 )
        self:setHorizontalStep(3)
	  end
    end

  end
  
end



function Player:die(reason)
  sound.sounds.playerDeath:play()
  self:destroy()
end
