require "Secretary"
require "Button"

-- Required fluff for classes
Menu = {}
Menu.__index = Menu

setmetatable(Menu, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

function Menu:_init( title, x, y, w, h )
  
  -- Validate parameters
  assertType(title, "title", "string")
  assertType(x, "x", "number")
  assertType(y, "y", "number")
  assertType(w, "w", "number")
  assertType(h, "h", "number")
  
  -- Initialize properties
  self.title = title
  self.x = x
  self.y = y
  self.width = w
  self.height = h
  self.border = 4
  self.items = {}
  
  -- Register events
  Secretary.registerEventListener(self, self.onKeyboardDown, EventType.KEYBOARD_DOWN)
  Secretary.registerEventListener(self, self.draw, EventType.DRAW)
  Secretary.setDrawLayer(self, DrawLayer.UI)
  
end



function Menu:destroy( )
  
  -- Destroy menu items
  for i,item in ipairs(self.items) do
    Secretary.remove(item)
  end
  
  -- Destroy self
  Secretary.remove(self)
  
end



function Menu:addItem( item )

  -- Validate parameters
  assertType(item, "item", Button)
  
  -- Add item to menu
  table.insert(self.items, item)
  Secretary.setDrawLayer(item, DrawLayer.UI)
  
end



function Menu:onKeyboardDown( key, isRepeat )
  -- TODO: menu selection
end



function Menu:draw( )
  
  -- White outline
  love.graphics.setColor( 255, 255, 255 )
  love.graphics.rectangle( "fill", self.x, self.y, self.width, self.height )
  
  -- Black background
  love.graphics.setColor( 0, 0, 0 )
  love.graphics.rectangle( "fill", self.x + self.border, self.y + self.border, self.width - self.border * 2, self.height - self.border * 2 )
  
end



--
-- STATIC MENU CREATION FUNCTIONS
--

function Menu.createPauseMenu( )
  local menu = Menu("Pause Menu", 20, 20, 100, 200)
  
  menu:addItem(Button("Continue", menu.x+menu.border*2, menu.y+menu.border*2, menu.width-menu.border*4, 32, function()
    menu:destroy()
  end))
  
  menu:addItem(Button("Quit", menu.x+menu.border*2, menu.y+menu.height-32-menu.border*2, menu.width-menu.border*4, 32, function()
    love.event.quit()
  end))
  
  menu:addItem(Button("Level 1", menu.x+menu.border*2, menu.y+menu.border*3+32, menu.width-menu.border*4, 32, function()
    clearEnemies()
    for _,obj in pairs(room.objects) do
      Secretary.remove(obj)
    end
    Secretary.remove(room)
    room = buildLevelFromFile("level1.txt")
    menu:destroy()
  end))
  
  
  menu:addItem(Button("Level 2", menu.x+menu.border*2, menu.y+menu.border*4+32*2, menu.width-menu.border*4, 32, function()
    clearEnemies()
    for _,obj in pairs(room.objects) do
      Secretary.remove(obj)
    end
    Secretary.remove(room)
    room = buildLevelFromFile("level2.txt")
    menu:destroy()
  end))
  
  return menu
end
