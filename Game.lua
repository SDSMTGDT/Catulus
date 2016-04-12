require "common/functions"
require "common/class"
require "Secretary"
require "Level"

Game = buildClass()

function Game:_init(secretary)
  
  -- Verify parameters
  assertType(secretary, "secretary", Secretary)
  
  -- The secretary to use for new object entities
  self.rootSecretary = secretary
  self.secretary = nil
  
  -- Flag indicating that a game is currently running
  self.running = false
  
  -- Handle to the main player object
  self.player = nil
end



function Game:startGame()
  
  -- Short-circuit if game is already running
  if self.running then
    return
  else
    self.running = true
  end
  
  self.secretary = Secretary()
  self.rootSecretary:registerChildSecretary(self.secretary)
  
  if self.room ~= nil then
    self.room:registerWithSecretary(self.secretary)
    self.room:registerChildrenWithSecretary(self.secretary)
  end
  
  local pos = self.room.playerSpawnPoints[math.random(table.getn(self.room.playerSpawnPoints))]
  self.player = Player():registerWithSecretary(self.secretary)
  self.player:setPosition(pos.x, pos.y)
  self.player:setVelocity(0, 0)
  
  camera.bound.xmin = 0
  camera.bound.xmax = self.room.width
  camera.bound.ymin = 0
  camera.bound.ymax = self.room.height
  camera:track(self.player)
  
  sound.music:play()
end



function Game:endGame()
  
  -- Short-circuit if game is not running
  if self.running == false then
    return
  else
    self.running = false
  end
  
  self.rootSecretary:remove(self.secretary)
  
  if self.room ~= nil then
    self.rootSecretary:remove(self.room)
  end
end



function Game:isRunning()
  return self.running
end



function Game:setPaused(paused)
  
  -- Verify parameters
  assertType(paused, "paused", "boolean")
  
  if self:isRunning() then
    self.secretary:setPaused(paused)
  end
end



function Game:isPaused()
  return self.secretary:isPaused()
end



function Game:pause()
  if self:isPaused() then
    return
  end
  if self:isRunning() == false then
    return
  end
  
  Menu.createPauseMenu(self.rootSecretary, self.secretary, camera, self)
end



function Game:loadLevel(levelName)
  self.room = Level(levelName)
  camera:setDimensions(self.room.width, self.room.height)
  
  if self:isRunning() then
    self.room:registerWithSecretary(self.secretary)
    self.room:registerChildrenWithSecretary(self.secretary)
  end
end