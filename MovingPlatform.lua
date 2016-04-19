require "PassthroughBlock"

MovingPlatform = buildClass(PassthroughBlock)

function MovingPlatform:_init(x, y, w, h, x2, y2, time)
  PassthroughBlock._init(self, x, y, w, h)
  
  self.from = {x = x, y = y}
  self.to = {x = x2, y = y2}
  self.time = time
  
  self.timer = 0
end

function MovingPlatform:update()
  
  -- Calculate motion
  if self.timer == 0 then
    self:setVelocity((self.to.x - self.from.x) / self.time, (self.to.y - self.from.y) / self.time)
  elseif self.timer == self.time then
    self:setVelocity(-(self.to.x - self.from.x) / self.time, -(self.to.y - self.from.y) / self.time)
  end
  self.timer = (self.timer + 1) % (self.time * 2)
  
  -- Track all the objects riding this moving platform
  local x, y = self:getPosition()
  local t, r, b, l = self:getBoundingBox(0, -1)
  local riders = self:getSecretary():getCollisions(t, r, b, l, Actor)
  
  -- Eliminate invalid riders
  local lasti = 1
  for i,rider in ipairs(riders) do
    local _,_,ob,_ = rider:getBoundingBox()
    if ob ~= t + 1 then
      riders[i] = nil
    else
      if i ~= lasti then
        riders[lasti] = rider
        riders[i] = nil
      end
      lasti = lasti + 1
    end
  end
  
  -- Call superclass's update function
  PassthroughBlock.update(self)
  
  -- Calculate offset
  local x2, y2 = self:getPosition()
  local dx = x2 - x
  local dy = y2 - y
  
  -- Move all the riders!
  for _,rider in ipairs(riders) do
    x, y = rider:getPosition()
    rider:setPosition(x + dx, y + dy)
  end
end