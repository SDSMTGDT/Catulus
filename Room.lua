require "common/class"
require "Entity"

Room = buildClass(Entity)

---------------------------------
-- BEGIN Room CLASS DEFINITION --
---------------------------------

--
-- Constructor
--
function Room:_init( )
  Entity._init(self)
  
  self.width = 0
  self.height = 0
  
  -- internal list of owned objects
  self.objects = {}
  self.enemySpawnPoints = {}
  self.playerSpawnPoints = {}
  
  self.timer = 0
end



function Room:registerWithSecretary(secretary)
  Entity.registerWithSecretary(self, secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.drawBars, EventType.DRAW)
  secretary:setDrawLayer(self, DrawLayer.OVERLAY)
  secretary:registerEventListener(self, self.onStep, EventType.STEP)
  secretary:registerEventListener(self, self.onKeyPress, EventType.KEYBOARD_DOWN)
  
  return self
end



function Room:registerChildrenWithSecretary(secretary)
  for _,object in ipairs(self.objects) do
    object:registerWithSecretary(secretary)
  end
end



function Room:addObject(object)
  assertType(object, "object", Entity)
  
  table.insert(self.objects, object)
end



function Room:addEnemySpawnPoint(x, y)
  assertType(x, "x", "number")
  assertType(y, "y", "number")
  
  table.insert(self.enemySpawnPoints, {x=x,y=y})
end



function Room:addPlayerSpawnPoint(x, y)
  assertType(x, "x", "number")
  assertType(y, "y", "number")
  
  table.insert(self.playerSpawnPoints, {x=x,y=y})
end



--
-- Adjust room dimensions
--
function Room:setDimensions( w, h )
  self.width = w
  self.height = h
  
  -- Allow onWindowResize to recalculate values
  camera:setDimensions(love.graphics.getWidth(), love.graphics.getHeight())
end




-- Draw black bars surrounding the room
function Room:drawBars( )
  
  love.graphics.setColor(0, 0, 0)
  
  
  local w = 32
  love.graphics.rectangle("fill", -w, 0, w, self.height)
  love.graphics.rectangle("fill", self.width, 0, w, self.height)
  local h = 64
  love.graphics.rectangle("fill", 0, -h, self.width, h)
  love.graphics.rectangle("fill", 0, self.height, self.width, h)
end


function Room:onStep( )
  self.timer = self.timer + 1
  if self.timer == 100 then
    self.timer = 0
    self:spawnKitty()
  end
end

function Room:onKeyPress(key, isrepeat)
  if key == "return" and isrepeat == false then
    self:spawnKitty()
  end
end


function Room:spawnKitty()
  if self:getSecretary():isPaused() == false then
    local e = Enemy():registerWithSecretary(self:getSecretary())
    local p = self.enemySpawnPoints[math.random(table.getn(self.enemySpawnPoints))]
    e:setPosition(p.x, p.y)
    if math.random(2) == 1 then
      e:moveLeft()
    else
      e:moveRight()
    end
    
    self:getSecretary():registerEventListener(self, function(self, kitty)
        print("kitty got deaded: ", kitty)
    end, EventType.DESTROY, e)
  end
end
  