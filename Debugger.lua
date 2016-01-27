require "common/class"
require "Secretary"

Debugger = buildClass()

function Debugger:_init()
  self.fps = 0
  self.physObjectCount = 0
  self.lastTime = love.timer.getTime()
  
  rootSecretary:registerEventListener(self, self.step, EventType.STEP)
  rootSecretary:registerEventListener(self, self.draw, EventType.DRAW)
end

function Debugger:step()
  self.physObjectCount = gameSecretary.tree:getSize()
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
