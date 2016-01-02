-- Required fluff for classes
Room = {}
Room.__index = Room

-- Syntax is very weird in this section, but it's necessary for classes
setmetatable(Room, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

---------------------------------
-- BEGIN Room CLASS DEFINITION --
---------------------------------

--
-- Constructor
--
function Room:_init( )
  self.width = 0
  self.height = 0
  
  -- auto-calculated values
  self.scale = 1
  self.offset = {}
  self.offset.x = 0
  self.offset.y = 0
  
  -- internal list of owned objects
  self.objects = {}
  
  Secretary.registerEventListener(self, self.adjustCanvas, EventType.PRE_DRAW)
  Secretary.registerEventListener(self, self.onWindowResize, EventType.WINDOW_RESIZE)
  Secretary.registerEventListener(self, self.drawBars, EventType.DRAW)
  Secretary.setDrawLayer(self, DrawLayer.OVERLAY)
end

--
-- Adjust room dimensions
--
function Room:setDimensions( w, h )
  self.width = w
  self.height = h
  
  -- Allow onWindowResize to recalculate values
  self:onWindowResize(love.graphics.getWidth(), love.graphics.getHeight())
end

--
-- Adjust to window resizes
--
function Room:onWindowResize( w, h )
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

function Room:drawingPoint(x, y)
  x = x or 0
  y = y or 0
  return (x - self.offset.x) / self.scale, (y - self.offset.y) / self.scale
end

function Room:drawingScale(w, h)
  w = w or 1
  h = h or 1
  return w * self.scale, h * self.scale
end

-- Adjust love's drawing offset and scale
function Room:adjustCanvas( )
  love.graphics.origin()
  love.graphics.translate( self.offset.x, self.offset.y )
  love.graphics.scale( self.scale, self.scale )
end

-- Draw black bars surrounding the room
function Room:drawBars( )
  if self.offset.x == 0 and self.offset.y == 0 then return end
  
  love.graphics.setColor(200, 200, 255)
  
  if self.offset.x > 0 then
    local w = self.offset.x / self.scale
    love.graphics.rectangle("fill", -w, 0, w, self.height)
    love.graphics.rectangle("fill", self.width, 0, w, self.height)
  elseif self.offset.y > 0 then
    local h = self.offset.y / self.scale
    love.graphics.rectangle("fill", 0, -h, self.width, h)
    love.graphics.rectangle("fill", 0, self.height, self.width, h)
  end
end
