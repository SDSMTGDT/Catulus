require "common/class"
require "Secretary"
require "Button"
require "Entity"
require "Room"
require "Game"

Menu = buildClass(Entity)

function Menu:_init( gameSecretary, title, x, y, w, h )
  Object:_init(self)
  
  -- Validate parameters
  assertType(gameSecretary, "gameSecretary", Secretary)
  assertType(title, "title", "string")
  assertType(x, "x", "number")
  assertType(y, "y", "number")
  assertType(w, "w", "number")
  assertType(h, "h", "number")
  
  -- Initialize properties
  self.gameSecretary = gameSecretary
  self.title = title
  self.x = x
  self.y = y
  self.width = w
  self.height = h
  self.border = 0
  self.padding = 0
  self.items = {n = 0, selected = 0}
end



function Menu:destroy( )
  Entity.destroy(self)
  
  -- Destroy menu items
  for i,item in ipairs(self.items) do
    item:destroy()
  end
  
  -- Destroy self
  self.gameSecretary:setPaused(false)
end



function Menu:registerWithSecretary(secretary)
  Entity.registerWithSecretary(self, secretary)
  
  -- Register events
  secretary:registerEventListener(self, self.onKeyboardDown, EventType.KEYBOARD_DOWN)
  secretary:registerEventListener(self, self.draw, EventType.DRAW)
  secretary:setDrawLayer(self, DrawLayer.UI)
  
  return self
end



function Menu:addItem( item )

  -- Validate parameters
  assertType(item, "item", Button)
  
  -- Add item to menu
  table.insert(self.items, item)
  self.items.n = self.items.n + 1
  self:getSecretary():setDrawLayer(item, DrawLayer.UI)
  
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
  
    -- Destroy self
  elseif key == "escape" then
    self:destroy()
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

function Menu.createPauseMenu( rootSecretary, gameSecretary, camera, game )
  
  assertType(rootSecretary, "rootSecretary", Secretary)
  assertType(gameSecretary, "gameSecretary", Secretary)
  assertType(camera, "camera", Camera)
  assertType(game, "game", Game)
  gameSecretary.paused = true
  
  -- Create new instance of menu
  local menu = Menu(gameSecretary, "Pause Menu", 20, 20, 200, 200):registerWithSecretary(rootSecretary)
  menu.padding = 8
  menu.border = 4
  
  -- Center menu
  menu.x = (camera.width - menu.width) / 2
  menu.y = (camera.height - menu.height + camera.offset.y) / 2
  
  menu:addItem(Button("Continue",
      menu.x + menu.border + menu.padding,
      menu.y + menu.border + menu.padding,
      menu.width - menu.border*2 - menu.padding*2,
      32,
      camera,
      function()
        menu:destroy()
      end):registerWithSecretary(rootSecretary))
  
  menu:addItem(Button("Level 1",
      menu.x + menu.border + menu.padding,
      menu.y + menu.border + menu.padding*2 + 32*1,
      menu.width - menu.border*2 - menu.padding*2,
      32,
      camera,
      function()
        game:endGame()
        game:loadLevel("level1.txt")
        game:startGame()
        menu:destroy()
      end):registerWithSecretary(rootSecretary))
  
  
  menu:addItem(Button("Level 2",
      menu.x + menu.border + menu.padding,
      menu.y + menu.border + menu.padding*3 + 32*2,
      menu.width - menu.border*2 - menu.padding*2,
      32,
      camera,
      function()
        game:endGame()
        game:loadLevel("level2.txt")
        game:startGame()
        menu:destroy()
      end):registerWithSecretary(rootSecretary))
  
  menu:addItem(Button("Quit",
      menu.x + menu.border + menu.padding,
      menu.y + menu.height - menu.border - menu.padding - 32,
      menu.width - menu.border*2 - menu.padding*2,
      32,
      camera,
      function()
        love.event.quit()
      end):registerWithSecretary(rootSecretary))
  
  return menu
end
