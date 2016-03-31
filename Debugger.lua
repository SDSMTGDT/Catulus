require "common/class"
require "Secretary"

Debugger = buildClass(Entity)

function Debugger:_init()
  Entity._init(self)
  self.fps = 0
  self.physObjectCount = 0
  self.lastTime = love.timer.getTime()
  self.kittens = 0
end

function Debugger:registerWithSecretary(secretary)
  Entity.registerWithSecretary(self, secretary)
  
  secretary:registerEventListener(self, self.step, EventType.STEP)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
  secretary:setDrawLayer(self, DrawLayer.OVERLAY)
  
  return self
end

function Debugger:step()
  if game:isRunning() then
    self.physObjectCount = game.secretary.tree:getSize()
  else
    self.physObjectCount = 0
  end
  self.fps = love.timer.getFPS()
  self.kittens = game.player.capturedKittens
end

function Debugger:draw()
  
  -- Draws a black background
  love.graphics.setColor(0, 0, 0, 127)
  love.graphics.rectangle("fill", 0, 0, 150, 75)
  
  -- Draws debug text
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("FPS: "..self.fps, 10, 10)
  love.graphics.print("Entities: "..self.physObjectCount, 10, 30)
  love.graphics.print("Kittens Captured: "..self.kittens, 10, 50)
end
