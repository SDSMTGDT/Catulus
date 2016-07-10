require "common/class"
require "Secretary"

Debugger = buildClass(Entity)

function Debugger:_init()
  Entity._init(self)
  self.fps = 0
  self.physObjectCount = 0
  self.lastTime = love.timer.getTime()
  self.visible = false
end

function Debugger:registerWithSecretary(secretary)
  Entity.registerWithSecretary(self, secretary)
  
  secretary:registerEventListener(self, self.step, EventType.STEP)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
  secretary:registerEventListener(self, self.onKeyPress, EventType.KEYBOARD_DOWN)
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
end

function Debugger:onKeyPress(key, scancode, isrepeat)
  
  -- Ignore repeat triggers
  if isrepeat then return false end
  
  -- Toggle visibility
  if key == "f4" then
    self.visible = self.visible == false
  end
end

function Debugger:draw()
  
  -- Short-circuit if we're invisible
  if self.visible == false then return end
  
  -- Draws a black background
  love.graphics.setColor(0, 0, 0, 127)
  love.graphics.rectangle("fill", camera.offset.x + 0, camera.offset.y + 0, 150, 75)
  
  -- Draws debug text
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("FPS: "..self.fps, camera.offset.x + 10, camera.offset.y + 10)
  love.graphics.print("Entities: "..self.physObjectCount, camera.offset.x + 10, camera.offset.y + 30)
end
