require "common/class"
require "Secretary"
require "Button"

Menu = buildClass()

function Menu:_init( title, x, y, w, h )
  Object:_init(self)
  
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
  self.border = 0
  self.padding = 0
  self.items = {n = 0, selected = 0}
  
  -- Register events
  rootSecretary:registerEventListener(self, self.onKeyboardDown, EventType.KEYBOARD_DOWN)
  rootSecretary:registerEventListener(self, self.draw, EventType.DRAW)
  rootSecretary:setDrawLayer(self, DrawLayer.UI)
  
end



function Menu:destroy( )
  
  -- Destroy menu items
  for i,item in ipairs(self.items) do
    rootSecretary:remove(item)
  end
  
  -- Destroy self
  rootSecretary:remove(self)
  gameSecretary.paused = false
  
end



function Menu:addItem( item )

  -- Validate parameters
  assertType(item, "item", Button)
  
  -- Add item to menu
  table.insert(self.items, item)
  self.items.n = self.items.n + 1
  rootSecretary:setDrawLayer(item, DrawLayer.UI)
  
end



function Menu:onKeyboardDown( key, isRepeat )
  
  -- Short circuit
  if self.items.n == 0 then return end
  
  -- De-select previous button
  if self.items.selected ~= 0 and self.items[self.items.selected] ~= nil then
    self.items[self.items.selected].selected = false
  end
  
  -- Select next button up
  if key == "up" then
    if self.items.selected <= 1 then
      self.items.selected = self.items.n
    else
      self.items.selected = self.items.selected - 1
    end
    
  -- Select next button down
  elseif key == "down" then
    if self.items.selected == 0 or self.items.selected == self.items.n then
      self.items.selected = 1
    else
      self.items.selected = self.items.selected + 1
    end
  end
  
  -- Select new button
  if self.items[self.items.selected] ~= nil then
    self.items[self.items.selected].selected = true
  end
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
  
  gameSecretary.paused = true
  
  -- Create new instance of menu
  local menu = Menu("Pause Menu", 20, 20, 200, 200)
  menu.padding = 8
  menu.border = 4
  
  -- Center menu
  menu.x = (room.width - menu.width) / 2
  menu.y = (room.height - menu.height) / 2
  
  menu:addItem(Button("Continue",
      menu.x + menu.border + menu.padding,
      menu.y + menu.border + menu.padding,
      menu.width - menu.border*2 - menu.padding*2,
      32,
      function()
        menu:destroy()
      end):registerWithSecretary(rootSecretary))
  
  menu:addItem(Button("Level 1",
      menu.x + menu.border + menu.padding,
      menu.y + menu.border + menu.padding*2 + 32*1,
      menu.width - menu.border*2 - menu.padding*2,
      32,
      function()
        clearEnemies()
        for _,obj in pairs(room.objects) do
          gameSecretary:remove(obj)
        end
        gameSecretary:remove(room)
        room = buildLevelFromFile("level1.txt")
        menu:destroy()
      end):registerWithSecretary(rootSecretary))
  
  
  menu:addItem(Button("Level 2",
      menu.x + menu.border + menu.padding,
      menu.y + menu.border + menu.padding*3 + 32*2,
      menu.width - menu.border*2 - menu.padding*2,
      32,
      function()
        clearEnemies()
        for _,obj in pairs(room.objects) do
          gameSecretary:remove(obj)
        end
        gameSecretary:remove(room)
        room = buildLevelFromFile("level2.txt")
        menu:destroy()
      end):registerWithSecretary(rootSecretary))
  
  menu:addItem(Button("Quit",
      menu.x + menu.border + menu.padding,
      menu.y + menu.height - menu.border - menu.padding - 32,
      menu.width - menu.border*2 - menu.padding*2,
      32,
      function()
        love.event.quit()
      end):registerWithSecretary(rootSecretary))
  
  return menu
end
