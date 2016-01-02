require "Secretary"

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
function Button:_init( text, x, y, w, h, action )

  self.text = text or ""
  self.x = x or 0
  self.y = y or 0
  self.width = w or 32
  self.height = h or 32
  self.padding = 4
  self.border = 4
  
  self.hover = false
  self.down = false
  self.selected = false
  
  self.actions = {}
  self.actions.click = action
  self.actions.hover = nil
  self.actions.unhover = nil
  
  rootSecretary:registerEventListener(self, self.onKeyboardDown, EventType.KEYBOARD_DOWN)
  rootSecretary:registerEventListener(self, self.onKeyboardUp, EventType.KEYBOARD_UP)
  rootSecretary:registerEventListener(self, self.onMouseMove, EventType.MOUSE_MOVE)
  rootSecretary:registerEventListener(self, self.onMouseDown, EventType.MOUSE_DOWN)
  rootSecretary:registerEventListener(self, self.onMouseUp, EventType.MOUSE_UP)
  rootSecretary:registerEventListener(self, self.draw, EventType.DRAW)
end



--
-- Button:setOnClickAction
--
function Button:setOnClickAction(action)
  
  -- Verify parameters
  assert(type(action) == "function" or action == nil, "Expected parameter of type 'function' or nil, '" .. type(action) .. "' received")
  self.actions.click = action
end

--
-- Button:setOnHoverAction
--
function Button:setOnHoverAction(action)
  
  -- Verify parameters
  assert(type(action) == "function" or action == nil, "Expected parameter of type 'function' or nil, '" .. type(action) .. "' received")
  self.actions.hover = action
end

--
-- Button:setOnUnhoverAction
--
function Button:setOnUnhoverAction(action)
  
  -- Verify parameters
  assert(type(action) == "function" or action == nil, "Expected parameter of type 'function' or nil, '" .. type(action) .. "' received")
  self.actions.unhover = action
end



--
-- Button:onKeyboardDown
--
function Button:onKeyboardDown( key, isRepeat )
  if self.selected and key == "return" then
    self.down = true  
  end
end

--
-- Button:onKeyboardUp
function Button:onKeyboardUp( key )
  if self.selected and key == "return" then
    if self.down then
      self.down = false
      onClick()
    end
  end
end



--
-- Button:onMouseMove
--
function Button:onMouseMove( x, y )
  
  x, y = room:drawingPoint(x, y)
  
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
  if self.actions.hover ~= nil then
    self.actions.hover()
  end
end

--
-- Button:onMouseOff
--
function Button:onMouseOff( )
  if self.actions.unhover ~= nil then
    self.actions.unhover()
  end
end

--
-- Button:onMousePressed
--
function Button:onMouseDown( x, y, button )
  x, y = room:drawingPoint(x, y)
  
  if button ~= "l" then return end
  
  if x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height then
    self.down = true
  end
end

--
-- Button:onMouseUp
--
function Button:onMouseUp( x, y, button )
  x, y = room:drawingPoint(x, y)
  
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
  if self.actions.click ~= nil then
    self.actions.click()
  end
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
  if self.hover == false and self.selected == false then
    love.graphics.setColor( 0, 0, 0 )
    love.graphics.rectangle( "fill", self.x + self.border, self.y + self.border, self.width - self.border * 2, self.height - self.border * 2 )
  end
  
  -- Text
  if self.hover == false and self.selected == false then
    love.graphics.setColor( 255, 255, 255 )
  else
    love.graphics.setColor( 0, 0, 0 )
  end
  love.graphics.printf( self.text, self.x + self.border + self.padding, self.y + self.border + self.padding, self.width - (self.border + self.padding) * 2, "center" )
  
  -- Restore color
  love.graphics.setColor( r, g, b, a )
  
end
