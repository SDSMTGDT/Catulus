-- Enum
-- Event types; used for event registration
EventType = {
  DRAW = 1,
  STEP = 2,
  PHYSICS = 3,
  KEYBOARD_DOWN = 4,
  KEYBOARD_UP = 5,
  MOUSE_DOWN = 6,
  MOUSE_UP = 7,
  
  values = function()
    local i = 0
    return function()
      i = i + 1
      if i <= 7 then return i end
    end
  end,
  
  fromId = function(id)
    if id > 7 or id < 1 then
      return nil
    else
      return id
    end
  end,
}
