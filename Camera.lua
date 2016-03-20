require "common/class"
require "Entity"

Camera = buildClass(Entity)

function Camera:_init( )
  Entity._init(self)

  -- auto-calculated values
  self.scale = 1
  self.offset = {}
  self.offset.x = 0
  self.offset.y = 0
  self.width = 1
  self.height = 1
  self.track = nil
  self.bound = {}
  self.bound.xmin = 0
  self.bound.xmax = 0
  self.bound.ymax = 0
  self.bound.ymin = 0
end

--
-- Adjust to window resizes
--
function Camera:onWindowResize( w, h )
  local room_ratio = self.width / self.height
  local calc_width = h * room_ratio
  local calc_height = w / room_ratio
  
  if calc_height > h then -- window height is smaller of the two, so scale from that
    self.scale = h / self.height
    self.offset.y = 0
    self.offset.x = (w - (self.width * self.scale)) / 2
  else -- window width is smaller, of the two, so scale from that
    self.scale = w / self.width
    self.offset.x = 0
    self.offset.y = (h - (self.height * self.scale)) / 2
  end
end



function Camera:registerWithSecretary(secretary)
  Entity.registerWithSecretary(self, secretary)
  
  -- Register for event callbacks
  secretary:registerEventListener(self, self.adjustCanvas, EventType.PRE_DRAW)
  secretary:registerEventListener(self, self.onWindowResize, EventType.WINDOW_RESIZE)
  secretary:registerEventListener(self, self.onStep, EventType.STEP)
  
  return self
end



function Camera:drawingPoint(x, y)
  x = x or 0
  y = y or 0
  return (x - self.offset.x) / self.scale, (y + self.offset.y) / self.scale
end



function Camera:drawingScale(w, h)
  w = w or 1
  h = h or 1
  return w * self.scale, h * self.scale
end



-- Adjust love's drawing offset and scale
function Camera:adjustCanvas( )
  love.graphics.origin()
  love.graphics.translate( -self.offset.x, -self.offset.y )
  love.graphics.scale( self.scale, self.scale )
end


function Camera:setDimensions(w, h)
  self.width = w or 1
  self.height = h or 1
  love.window.setMode(self.width, self.height, {resizable=true})
end


function Camera:onStep( )
  if self.track ~= nil then
    local x, y, z = self.track:getPosition()
    self.offset.y = y - self.height / 2
  end
  
  if self.offset.y < self.bound.ymin then
    self.offset.y = self.bound.ymin
  elseif self.offset.y + self.height > self.bound.ymax then
    self.offset.y = self.bound.ymax - self.height
  elseif self.offset.x < self.bound.xmin then
    self.offset.x = self.bound.xmin
  elseif self.offset.x > self.bound.xmax - self.width then
    self.offset.x = self.bound.xmax - self.width
  end
    
  
end


function Camera:track(object)
  assertType(object, "object", PhysObject)
  self.track = object
end