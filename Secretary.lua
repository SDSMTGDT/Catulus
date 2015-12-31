require "functions"
require "QuadTree"
require "EventType"
require "DrawLayer"

-- Required fluff for classes
Secretary = {}
Secretary.__index = Secretary

-- Syntax is very weird in this section, but it's necessary for classes
setmetatable(Secretary, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

Secretary.tree = QuadTree( 1, -1000, 1000, -1000, 1000 ) -- Collision detection data structure

Secretary.objectNodes = {}  -- table containing direct references to object quadtree nodes
Secretary.callbacks = {}    -- table containing all callbacks

-- Prepare callback lists
for t in EventType.values() do
  Secretary.callbacks[t] = {n = 0}
end

for l in DrawLayer.values() do
  Secretary.callbacks[EventType.DRAW][l] = {n = 0}
  if Secretary.callbacks[EventType.DRAW][l].n < l then
    Secretary.callbacks[EventType.DRAW][l].n = l
  end
end





--------------------------------------------------------------------------------
--                            COLLISION SYSTEM                                --
--------------------------------------------------------------------------------

--
-- Registers a new PhysObject with the Secretary.
--
-- object: The new object to track collisions with.
--
function Secretary.registerPhysObject( object )
  
  -- Validate arguments
  assert(instanceOf(object, PhysObject), "Argument must be an instance of PhysObject")
  assert(Secretary.objectNodes[object] == nil, "PhysObject already registered with the secretary")
  
  -- Store full node path
  Secretary.objectNodes[object] = Secretary.tree:insert(object)
end

--
-- Unregisters a PhysObject with the Secretary, removing them from collision
-- checks and data structures.
--
-- object: The object to unregister.
--
function Secretary.unregisterPhysObject( object )
  
  -- Validate arguments
  assert(instanceOf(object, PhysObject), "Argument must be an instance of PhysObject")
  
  -- Remove object from quadtree
  Secretary.tree:remove(object, Secretary.objectNodes[object])
end

--
-- Updates an object's status in the quadtree and other lists, updating caches
-- and indexes for fast access.
--
-- object: The object to update information for.
--
function Secretary.updateObject(object)
  local path = Secretary.tree:getFullIndex(object:getBoundingBox())
  
  if path ~= Secretary.objectNodes[object] then
    Secretary.tree:remove(object, Secretary.objectNodes[object])
    path = Secretary.tree:insert(object)
    Secretary.objectNodes[object] = path
  end
end

--
-- Gets a list of all registered objets whose bouding boxes intersect with the
-- supplied bounds.
--
-- Parameters
--   top - required - number
--     Top coordinate of the bouding box to check.
--   right - required - number
--     Right coordinate of the bouding box to check.
--   bottom - required - number
--     Bottom coordinate of the bounding box to check.
--   left - required - number
--     Left coordinate of the bounding box to check.
--
-- Return
--   Table containing indexed array of objects whose bounding boxes intersect
--     with the supplied coordinates.
--
function Secretary.getCollisions( top, right, bottom, left )
  assert(top and right and bottom and left, "parameter(s) cannot be nil")
  
  -- Initialize variables
  local list = {}
  local i = 1
  
  -- Retrieve list of all possible collisions from tree
  Secretary.tree:retrieve( list, top, right, bottom, left )
  
  -- Remove objects from list that we do not collide with
  while i <= #list do
    if list[i]:collidesWith(top, right, bottom, left) == true then
      i = i + 1
    else
      table.remove(list, i)
    end
  end
  
  -- Return our compiled list
  return list
end

function Secretary.remove( object )
  if instanceOf(object, PhysObject) then
    Secretary.unregisterPhysObject(object)
  end
  Secretary.unregisterAllListeners(object)
end





--------------------------------------------------------------------------------
--                              EVENT SYSTEM                                  --
--------------------------------------------------------------------------------

--
-- Adds a function to the callback table, indexing by event type and by owning
-- object.
--
-- object: Table that "owns" the listener function
-- listener: Function to be called on event trigger. The "object" parameter will
--           be passed as the first argument, followed by any other parameters
--           that are required for the given event type.
-- eventType: type of event the listener is listening for.
--
function Secretary.registerEventListener( object, listener, eventType )
  
  -- Verify arguments
  assertType(object, "object", "table")
  assert (listener ~= nil, "Argument 'listener' cannot be nil")
  assert (eventType ~= nil, "Argument 'eventType' cannot be nil")
  eventType = EventType.fromId(eventType)
  assert (eventType ~= nil, "eventType must be a valid EventType")
  
  -- Create callback object
  local callback = {
    object = object,
    listener = listener,
    eventType = eventType,
    index = 0
  }
  
  -- Customize callback object based on callback type
  if eventType == EventType.DRAW then
    callback.drawLayer = DrawLayer.MAIN
  end
  
  -- Insert callback into callback table indexed by event type
  local callbacks = Secretary.callbacks[eventType]
  if eventType == EventType.DRAW then
    callbacks = callbacks[callback.drawLayer]
  end
  local n = callbacks.n + 1
  callbacks[n] = callback
  callbacks.n = n
  callback.index = n
  
  -- Create table entry for object if none exists
  if Secretary.callbacks[object] == nil then
    Secretary.callbacks[object] = {n = 0}
  end
  
  -- Insert callback into callback table indexed by calling object
  n = Secretary.callbacks[object].n + 1
  Secretary.callbacks[object][n] = callback
  Secretary.callbacks[object].n = n
  
end

--
-- Moves an object's draw callback(s) to a new draw layer.
--
-- object: Object whose draw function to move to drawLayer
-- drawLayer: New layer to move draw callback to
-- listener (optional): specific draw function to move to drawLayer
--     in case object has multiple draw callbacks registered
--
function Secretary.setDrawLayer( object, drawLayer, listener )
  
  -- Validate arguments
  assertType(object, "object", "table")
  assert(DrawLayer.fromId(drawLayer) ~= nil, "drawLayer must be a valid DrawLayer value")
  
  -- Make sure callbacks exist for the given object
  local callbacks = Secretary.callbacks[object]
  if callbacks == nil then
    return
  end
  
  -- Search through object's calbacks for a match with parameters
  for i, callback in ipairs(callbacks) do
    if callback and
       callback.eventType == EventType.DRAW and
       (listener == nil or callback.listener == nil) and
       callback.drawLayer ~= drawLayer then
      
      -- Remove from old drawing layer
      Secretary.callbacks[callback.eventType][callback.drawLayer][callback.index] = nil
      
      -- Insert into new layer at end of list
      local newCallbacks = Secretary.callbacks[callback.eventType][drawLayer]
      newCallbacks.n = newCallbacks.n + 1
      newCallbacks[newCallbacks.n] = callback
      
      -- Update values in callback
      callback.index = newCallbacks.n
      callback.drawLayer = drawLayer
    end
  end
end

--
-- Deletes all callbacks associated with the given object.
--
-- object: The object to delete all registered callbacks for.
--
function Secretary.unregisterAllListeners( object )
  
  -- Validate arguments
  assertType(object, "object", "table")
  
  -- Make sure callbacks exist for the given object
  local callbacks = Secretary.callbacks[object]
  if callbacks == nil then
    return
  end
  
  -- Remove each callback from it's eventType table
  for i,callback in ipairs(callbacks) do
    if callback then
      if callback.eventType == EventType.DRAW then
        Secretary.callbacks[callback.eventType][callback.drawLayer][callback.index] = nil
      else
        Secretary.callbacks[callback.eventType][callback.index] = nil
      end
    end
  end
  
  -- Remove this object from the callback table, finallizing the process
  Secretary.callbacks[object] = nil
end






--------------------------------------------------------------------------------
--                               EVENT FUNCTIONS                              --
--------------------------------------------------------------------------------


-- Called every draw step
function Secretary.onDraw()
  for l in DrawLayer.values() do
    Secretary.executeCallbacks(Secretary.callbacks[EventType.DRAW][l])
  end
end

-- Called every game step
function Secretary.onStep()
  Secretary.executeCallbacks(Secretary.callbacks[EventType.STEP])
end

-- Called before every physics event
function Secretary.onPrePhysics()
  Secretary.executeCallbacks(Secretary.callbacks[EventType.PRE_PHYSICS])
end

-- CAlled every step to execute physics
function Secretary.onPhysics()
  Secretary.executeCallbacks(Secretary.callbacks[EventType.PHYSICS])
end

-- Called after physics event
function Secretary.onPostPhysics()
  Secretary.executeCallbacks(Secretary.callbacks[EventType.POST_PHYSICS])
end

-- Called when a keyboard button is pressed
function Secretary.onKeyboardDown( key, isrepeat )
  Secretary.executeCallbacks(Secretary.callbacks[EventType.KEYBOARD_DOWN], key, isrepeat)
end

-- Called when a keyboard button is released
function Secretary.onKeyboardUp( key )
  Secretary.executeCallbacks(Secretary.callbacks[EventType.KEYBOARD_UP], key )
end

-- Called when a mouse button is pressed
function Secretary.onMouseDown(x, y, button)
  Secretary.executeCallbacks(Secretary.callbacks[EventType.MOUSE_DOWN], x, y, button)
end

-- Called when a mouse button is released
function Secretary.onMouseUp(x, y, button)
  Secretary.executeCallbacks(Secretary.callbacks[EventType.MOUSE_UP], x, y, button)
end

-- Called when the mouse is moved
function Secretary.onMouseMove(x, y, dx, dy)
  Secretary.executeCallbacks(Secretary.callbacks[EventType.MOUSE_MOVE], x, y, dx, dy)
end

-- Called when a joystick button is pressed
function Secretary.onJoystickDown(joystick, button)
  Secretary.executeCallbacks(Secretary.callbacks[EventType.JOYSTICK_DOWN], joystick, button)
end

-- Called when a joystick button is released
function Secretary.onJoystickUp(joystick, button)
  Secretary.executeCallbacks(Secretary.callbacks[EventType.JOYSTICK_UP], joystick, button)
end

-- Called when a joystick is connected
function Secretary.onJoystickAdd(joystick)
  Secretary.executeCallbacks(Secretary.callbacks[EventType.JOYSTICK_ADD], joystick)
end

-- Called when a joystick is released
function Secretary.onJoystickRemove(joystick)
  Secretary.executeCallbacks(Secretary.callbacks[EventType.JOYSTICK_REMOVE], joystick)
end

-- Called when the game window is resized
function Secretary.onWindowResize(w, h)
  Secretary.executeCallbacks(Secretary.callbacks[EventType.WINDOW_RESIZE], w, h)
end

-- Called before draw events are executed
function Secretary.onPreDraw()
  Secretary.executeCallbacks(Secretary.callbacks[EventType.PRE_DRAW])
end

-- Called when the game window is resized
function Secretary.onWindowResize(w, h)
  Secretary.executeCallbacks(Secretary.callbacks[EventType.WINDOW_RESIZE], w, h)
end

-- Called before draw events are executed
function Secretary.onPreDraw()
  Secretary.executeCallbacks(Secretary.callbacks[EventType.PRE_DRAW])
end



-- Generic function that executes callbacks for a given event type
-- Handles errors and takes any variable number of arguments and passes
-- them along to the callbacks.
function Secretary.executeCallbacks( callbacks, ... )
  local arg = {...}
  
  -- Execute all registered callbacks registered with Secretary
  local lastIndex = 0
  for i = 1,callbacks.n do
    local callback = callbacks[i]
    
    -- Ensure callback exists
    if callback then
      
      -- Attempt to fill any gaps in table (in event of deleted objects)
      lastIndex = lastIndex + 1
      if lastIndex < i then
        callbacks[lastIndex] = callback
        callback.index = lastIndex
        callbacks[i] = nil
      end
      
      -- Convenience variables
      local listener = callback.listener
      local object = callback.object
      
      -- Use xpcall to prevent errors from destroying everything
      local success, errmessage = xpcall(
        function() return listener(object, unpack(arg)) end,
        catchError    -- function to handle errors
      )
      
      -- If error occured, display traceback and continue
      if success == false then
        print("Error occured while handling event (type: "..eventType..")")
        print("Caused by:", errmessage)
      end
    end
  end
  
  -- If gaps were detected and closed, decrease size of callback table
  callbacks.n = lastIndex
end
