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
  return self.offset.x + (x * self.scale), self.offset.y + (y * self.scale)
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
  
end
