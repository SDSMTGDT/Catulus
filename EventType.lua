-- Enum
-- Event types; used for event registration
EventType = {
  DRAW = 1,
  STEP = 2,
  PRE_PHYSICS = 3,
  PHYSICS = 4,
  POST_PHYSICS = 5,
  KEYBOARD_DOWN = 6,
  KEYBOARD_UP = 7,
  MOUSE_DOWN = 8,
  MOUSE_UP = 9,
  MOUSE_MOVE = 10,
  JOYSTICK_DOWN = 11,
  JOYSTICK_UP = 12,
  JOYSTICK_ADD = 13,
  JOYSTICK_REMOVE = 14,
  WINDOW_RESIZE = 15,
  PRE_DRAW = 16,
  
  values = function( )
    local i = 0
    return function()
      i = i + 1
      if i <= 16 then return i end
    end
  end,
  
  fromId = function( id )
    if id > 16 or id < 1 then
      return nil
    else
      return id
    end
  end,
}
