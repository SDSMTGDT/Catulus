-- Required fluff for classes
Button = {}
Button.__index = Button

setmetatable(Button, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

-- 
-- Button constructor
--
function Button:_init( text, x, y, w, h )

  self.text = text or ""
  self.x = x or 0
  self.y = y or 0
  self.width = w or 32
  self.height = h or 32
  
  self.hover = false
  self.down = false
  self.padding = 4
  self.border = 4
  
end



--
-- Button:onMouseMove
--
function Button:onMouseMove( x, y )
  
  -- Trigger mouse hover events
  if x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height then
    if self.hover == false then
      self.hover = true
      self:onMouseOver()
    end
  else
    if self.hover == true then
      self.hover = false
      self:onMouseOff()
    end
  end
  
end

--
-- Button:onMouseOver
--
function Button:onMouseOver( )
  print("mouse hover")
end

--
-- Button:onMouseOff
--
function Button:onMouseOff( )
  print("mouse unhover")
end

--
-- Button:onMousePressed
--
function Button:onMouseDown( x, y, button )
  if button ~= "l" then return end
  
  if x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height then
    self.down = true
  end
end

--
-- Button:onMouseReleased
--
function Button:onMouseReleased( x, y, button )
  if button ~= "l" then return end
  
  -- Update flags
  local down = self.down
  self.down = false
  
  if down and x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height then
    self:onClick()
  end
end

--
-- Button:onClick
--
function Button:onClick( )
end

--
-- Button:draw
--
function Button:draw()
  
  -- Back up color
  local r, g, b, a = love.graphics.getColor()
  
  -- White outline
  love.graphics.setColor( 255, 255, 255 )
  if self.down and self.hover then
    love.graphics.rectangle( "fill", self.x - 2, self.y - 2, self.width + 4, self.height + 4 )
  else
    love.graphics.rectangle( "fill", self.x, self.y, self.width, self.height )
  end
  
  -- Black background
  if self.hover == false then
    love.graphics.setColor( 0, 0, 0 )
    love.graphics.rectangle( "fill", self.x + self.border, self.y + self.border, self.width - self.border * 2, self.height - self.border * 2 )
  end
  
  -- Text
  if self.hover == false then
    love.graphics.setColor( 255, 255, 255 )
  else
    love.graphics.setColor( 0, 0, 0 )
  end
  love.graphics.printf( self.text, self.x + self.border + self.padding, self.y + self.border + self.padding, self.width - (self.border + self.padding) * 2, "center" )
  
  -- Restore color
  love.graphics.setColor( r, g, b, a )
  
end
