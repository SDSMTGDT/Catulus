require "common/class"
require "Entity"

Room = buildClass(Entity)

---------------------------------
-- BEGIN Room CLASS DEFINITION --
---------------------------------

--
-- Constructor
--
function Room:_init( width, height )
  Entity._init(self)
  
  self.width = width or 0
  self.height = height or 0
  
  -- internal list of owned objects
  self.objects = {}
  self.enemySpawnPoints = {}
  self.playerSpawnPoints = {}
  self.enemies = {}
  self.enemiesCount = 0
  
  self.timer = 0
  
  
  love.window.setMode(width * 16, height * 16, {resizable=true})
  self:setDimensions(width * 16, height * 16)
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
    self:spawnEnemy()
  end
end

function Room:onKeyPress(key, isrepeat)
  if key == "return" and isrepeat == false then
    self:spawnEnemy()
  end
end


function Room:spawnEnemy()
  
  --Make sure there are any enemies to spawn
  if self.enemiesCount ~= 0 then
  
    if self:getSecretary():isPaused() == false then
      local enemyType = nil
      enemyCount = 0
      for _, count in pairs(self.enemies) do
        enemyCount = enemyCount + count
      end
      
      enemyCount = math.random(enemyCount)
      
      for index, count in pairs(self.enemies) do
          enemyCount = enemyCount - count

          if enemyCount < 0 then
            enemyType = index
            break
          end
      end

      local e = enemyType():registerWithSecretary(self:getSecretary())
      local p = self.enemySpawnPoints[enemyType][math.random(table.getn(self.enemySpawnPoints[enemyType]))]
      e:setPosition(p.x, p.y)
      print("Enemy Spawned")
      
      if self.enemies[enemyType] == 0 then
        self.enemies[enemyType] = nil
        self.enemiesCount = self.enemiesCount - 1
      end
    end
  end
end


function Room:buildBlock(x, y, w, h)
  self:addObject(Block( x, y, w, h))
end


function Room:addSpawn(spawn)
  for index, value in pairs(spawn.enemyTypes) do
    if self.enemySpawnPoints[value] == nil then
      self.enemySpawnPoints[value] = {spawn}
    else
      table.insert(self.enemySpawnPoints[value], spawn)
    end
  end
end


function Room:addEnemies(enemy, count)
  self.enemies[enemy] = count
  self.enemiesCount = self.enemiesCount + 1
end