require "functions"
require "QuadTree"
require "EventType"

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


Secretary.objects = {}
Secretary.nextId = 1
Secretary.tree = QuadTree( 1, -1000, 1000, -1000, 1000 )
Secretary.objectNodes = {}

-- Set up callback tables for fast event lookups
Secretary.callbacks = {}
for t in EventType.values() do Secretary.callbacks[t] = {} end


function Secretary.registerObject(object)
  
  -- Validate arguments
  assert (instanceOf(object, PhysObject), "Argument must be an instance of PhysObject")
  
  -- Make sure object ID is unset
  assert (object.id == nil, "Object already assigned an ID")
  
  -- Assign object an ID, add to data structures
  object.id = Secretary.nextId
  Secretary.objects[Secretary.nextId] = object
  
  -- Store full node path
  Secretary.objectNodes[Secretary.nextId] = Secretary.tree:insert(object)
  
  -- Increment ID for next object
  Secretary.nextId = Secretary.nextId + 1
  
  return true
end


function Secretary.registerEvent(object, eventType, callback)
  assert (object ~= nil, "Argument(s) cannot be nil")
  assert (eventType ~= nil, "Argument(s) cannot be nil")
  assert (callback ~= nil, "Argument(s) cannot be nil")
  
  local etype = EventType.fromId(eventType)
  assert (etype ~= nil, "eventType must be a valid EventType")
  
  assert (type(object.getInstanceId) == "function", "Object missing getInstanceId() method")
  
  local id = object:getInstanceId()
  assert (type(id) == "number", "Object ID must be of type number")
  assert (Secretary.objects[id] == object, "Object not registered with Secretary")
  
  assert (type(callback) == "function", "Callback must be a function")
  
  Secretary.callbacks[etype][id] = callback
end


function Secretary.updateObject(object)
  local path = Secretary.tree:getFullIndex(object:getBoundingBox())
  
  if path ~= Secretary.objectNodes[object.id] then
    Secretary.tree:remove(object, Secretary.objectNodes[object.id])
    path = Secretary.tree:insert(object)
    Secretary.objectNodes[object.id] = path
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


--
-- Gets a reference to the object registered under the given instance id.
--
-- Parameters
--   id - required - number
--     The instance id of the object to retrieve.
--
-- Return
--   Reference to the object with instance id equal to id, or nil if no objects
--     match the given id.
--
function Secretary.getObject( id )
  
  -- Validate arguments
  assert(id, "id cannot be nil")
  assert(type(id) == "number", "id must be a number")
  
  -- Look up entry in table (returns null if no entry exists)
  return Secretary.objects[id]
end


--
-- Removes an object from the Secretary. Removes any callbacks associated with
-- the object and removes object from collision checks.
-- 
-- Parameters
--   object - required - number or PhysObject
--     The object or the instace id of the object to delete from the secretary.
-- 
-- Return
--   nil
--
function Secretary.remove( object )
  -- Validate arguments
  assert( type(object) == "number" or instanceOf( object, PhysObject ), "Invalid parameter type" )
  local id = object
  
  -- Get ID if given object or object if given ID
  if type(id) == "number" then
    object = Secretary.objects[id]
    assert( object , "Invalid object ID "..id ) 
  else
    id = object:getInstanceId()
  end
  
  -- Remove object from tree and object lists
  Secretary.tree:remove(object, Secretary.objectNodes[id])
  Secretary.objects[id] = nil
  Secretary.objectNodes[id] = nil
  
  -- Remove object's registered event callback functions
  for t in EventType.values() do
    Secretary.callbacks[t][id] = nil
  end
end


--------------------------------------------------------------------------------
--                               EVENT FUNCTIONS                              --
--------------------------------------------------------------------------------


-- Called every draw step
function Secretary.onDraw()
  Secretary.executeCallbacks(EventType.DRAW)
end

-- Called every game step
function Secretary.onStep()
  Secretary.executeCallbacks(EventType.STEP)
end

-- Called before every physics event
function Secretary.onPrePhysics()
  Secretary.executeCallbacks(EventType.PRE_PHYSICS)
end

-- CAlled every step to execute physics
function Secretary.onPhysics()
  Secretary.executeCallbacks(EventType.PHYSICS)
end

-- Called after physics event
function Secretary.onPostPhysics()
  Secretary.executeCallbacks(EventType.POST_PHYSICS)
end

-- Called when a keyboard button is pressed
function Secretary.onKeyboardDown( key, isrepeat )
  Secretary.executeCallbacks(EventType.KEYBOARD_DOWN, key, isrepeat)
end

-- Called when a keyboard button is released
function Secretary.onKeyboardUp( key )
  Secretary.executeCallbacks(EventType.KEYBOARD_UP, key )
end

-- Called when a mouse button is pressed
function Secretary.onMouseDown(x, y, button)
  Secretary.executeCallbacks(EventType.MOUSE_DOWN, x, y, button)
end

-- Called when a mouse button is released
function Secretary.onMouseUp(x, y, button)
  Secretary.executeCallbacks(EventType.MOUSE_UP, x, y, button)
end

-- Called when the mouse is moved
function Secretary.onMouseMove(x, y, dx, dy)
  Secretary.executeCallbacks(EventType.MOUSE_MOVE, x, y, dx, dy)
end

-- Called when a joystick button is pressed
function Secretary.onJoystickDown(joystick, button)
  Secretary.executeCallbacks(EventType.JOYSTICK_DOWN, joystick, button)
end

-- Called when a joystick button is released
function Secretary.onJoystickUp(joystick, button)
  Secretary.executeCallbacks(EventType.JOYSTICK_UP, joystick, button)
end

-- Called when a joystick is connected
function Secretary.onJoystickAdd(joystick)
  Secretary.executeCallbacks(EventType.JOYSTICK_ADD, joystick)
end

-- Called when a joystick is released
function Secretary.onJoystickRemove(joystick)
  Secretary.executeCallbacks(EventType.JOYSTICK_REMOVE, joystick)
end


-- Generic function that executes callbacks for a given event type
-- Handles errors and takes any variable number of arguments and passes
-- them along to the callbacks.
function Secretary.executeCallbacks( eventType, ... )
  assert(EventType.fromId(eventType), "Invalid event type: "..eventType)
  local arg = {...}
  
  -- Execute all registered callbacks registered with Secretary
  for i,callback in pairs(Secretary.callbacks[eventType]) do
    
    -- Double-check that callback is real
    if callback then
      
      -- Use xpcall to prevent errors from destroying everything
      local success, errmessage = xpcall(
        function() return callback(Secretary.objects[i], unpack(arg)) end,
        catchError    -- function to handle errors
      )
      
      -- If error occured, display traceback and continue
      if success == false then
        print("Error occured while handling event (type: "..eventType..")")
        print("Caused by:", errmessage)
      end
    end
  end
end
