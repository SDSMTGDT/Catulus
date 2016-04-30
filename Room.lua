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


--
--Register the room with secretary
--
--secretary: The secretary to register with
--
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

--
--Adds an object to the Room
--
--object: An Entity object to add to the room
--
function Room:addObject(object)
  assertType(object, "object", Entity)
  
  table.insert(self.objects, object)
end


--
--Add a spawn point for the player character to the room
--
function Room:addPlayerSpawnPoint(x, y)
  --Make sure x and y are valid
  assertType(x, "x", "number")
  assertType(y, "y", "number")
  
  --Add the spawn point
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
  --Set color
  love.graphics.setColor(0, 0, 0)
  
  --Draw the bars
  local w = 32
  love.graphics.rectangle("fill", -w, 0, w, self.height)
  love.graphics.rectangle("fill", self.width, 0, w, self.height)
  local h = 64
  love.graphics.rectangle("fill", 0, -h, self.width, h)
  love.graphics.rectangle("fill", 0, self.height, self.width, h)
end


--This is called by the secretary each step
function Room:onStep( )
  self.timer = self.timer + 1
  
  --Spawn an enemy every second or so
  if self.timer == 100 then
    self.timer = 0
    self:spawnEnemy()
  end
end

--
--Spawn an enemy when enter is pressed
--
function Room:onKeyPress(key, isrepeat)
  if key == "return" and isrepeat == false then
    self:spawnEnemy()
  end
end


--
--Spawn an enemy at a random spawn point
--
function Room:spawnEnemy()
  --Make sure there are any enemies to spawn
  if self.enemiesCount > 0 then
  
    --Make sure the game is not paused
    if self:getSecretary():isPaused() == false then
      
      --Add up the total amount of enemies in the level
      local enemyType = nil
      totalEnemies = 0
      for _, count in pairs(self.enemies) do
        totalEnemies = totalEnemies + count
      end
      
      --Get a random number from 0 to totalEnemies
      enemyCount = math.random(totalEnemies)
      enemyType = nil
      
      --Loop through all the enemies in the level
      for index, count in pairs(self.enemies) do
          --Subtract the number of each type of enemy
          enemyCount = enemyCount - count

          --If enemyCount is less than 0, spawn the type the loop is on
          if enemyCount <= 0 then
            enemyType = index
            break
          end
      end
      
      --Check to make sure we got an enemy type
      if enemyType ~= nil then
        
        --Initialize new enemy and register with secretary
        local e = enemyType():registerWithSecretary(self:getSecretary())
        
        --Choose a random elegible spawn point
        local p = self.enemySpawnPoints[enemyType][math.random(table.getn(self.enemySpawnPoints[enemyType]))]
        
        --Give the enemy the position of the spawn point
        e:setPosition(p.x, p.y)
        
        --Remove the new enemy from spawnable enemies
        self.enemies[enemyType] = self.enemies[enemyType] - 1
        
        --Register death event for the new enemy
        self:getSecretary():registerEventListener(self, function(self, kitty)
          print("kitty got deaded: ", kitty)
          end, EventType.DESTROY, e)
      end
    end
  end
end

--
--Creates a block and add it to the room
--
function Room:buildBlock(x, y, w, h)
  self:addObject(SolidBlock( x, y, w, h))
end

--
--Add an enemy spawn point to the room
--
function Room:addSpawn(spawn)
  for index, value in pairs(spawn.enemyTypes) do
    if self.enemySpawnPoints[value] == nil then
      self.enemySpawnPoints[value] = {spawn}
    else
      table.insert(self.enemySpawnPoints[value], spawn)
    end
  end
end


--
--Add an enemy to the room
--
--enemy: The type of enemy to add to the room
--count: The number of enemies to add the the room
--
function Room:addEnemies(enemy, count)
  if enemy == nil or count == nil then
    return
  end
  
  if self.enemies[enemy] == nil then
    self.enemies[enemy] = count
    self.enemiesCount = self.enemiesCount + 1
  else
    self.enemies[enemy] = self.enemies[enemy] + count
  end
end