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
  MOUSE_MOVE = 8,
  JOYSTICK_DOWN = 9,
  JOYSTICK_UP = 10,
  JOYSTICK_ADD = 11,
  JOYSTICK_REMOVE = 12,
  
  values = function( )
    local i = 0
    return function()
      i = i + 1
      if i <= 12 then return i end
    end
  end,
  
  fromId = function( id )
    if id > 12 or id < 1 then
      return nil
    else
      return id
    end
  end,
}
