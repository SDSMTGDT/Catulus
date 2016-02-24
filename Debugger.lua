require "common/class"
require "Secretary"

Debugger = buildClass(Entity)

function Debugger:_init()
  self.fps = 0
  self.physObjectCount = 0
  self.lastTime = love.timer.getTime()
end

function Debugger:registerWithSecretary(secretary)
  Entity.registerWithSecretary(self, secretary)
  
  secretary:registerEventListener(self, self.step, EventType.STEP)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
  
  return self
end

function Debugger:step()
  self.physObjectCount = self:getSecretary().tree:getSize()
  self.fps = love.timer.getFPS()
end

function Debugger:draw()
  
  -- Draws a black background
  love.graphics.setColor(0, 0, 0, 127)
  love.graphics.rectangle("fill", 0, 0, 150, 75)
  
  -- Draws debug text
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("FPS: "..self.fps, 10, 10)
  love.graphics.print("Entities: "..self.physObjectCount, 10, 30)
end
