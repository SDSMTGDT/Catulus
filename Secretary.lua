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
  
  local etype = EventType.fromId(etype)
  assert (etype ~= nil, "eventType must be a valid EventType")
  
  assert (type(object.getInstanceId) ~= "function", "Object missing getInstanceId() method")
  
  local id = object:getInstanceId()
  assert (type(id) == "number", "Object ID must be of type number")
  assert (Secretary.objects[id] == object, "Object not registered with Secretary")
  
  assert (type(callback) == "function", "Callback must be a function")
  assert (Secregary.callbacks[etype][id] == nil, "Event type already registered for that object")
  
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


function Secretary.getCollisions( top, right, bottom, left )
  local list = {}
  local i = 1
  Secretary.tree:retrieve( list, top, right, bottom, left )
  
  while i <= #list do
    if list[i]:collidesWith(top, right, bottom, left) == true then
      i = i + 1
    else
      table.remove(list, i)
    end
  end
  
  return list
end


function Secretary.getObject( id )
  return Secretary.objects[id]
end


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

function Secretary.drawObjects( )
  for i, o in pairs(Secretary.objects) do
    o:draw()
  end
end
  
function Secretary.updatePhysics( )
  for i, o in pairs(Secretary.objects) do
    o:update()
  end
end

function Secretary.checkCollisions( )
  for i, o in pairs(Secretary.objects) do
    o:onCollisionCheck( )
  end
end


function Secretary.onKeyboardDown( key, isrepeat )
  Secretary.executeCallbacks(EventType.KEYBOARD_DOWN, key, isrepeat)
end


function Secretary.onKeyboardUp( key )
  Secretary.executeCallbacks(EventType.KEYBOARD_UP, key )
end


function Secretary.executeCallbacks( eventType, ... )
  assert(EventType.fromId(eventType), "Invalid event type: "..eventType)
  
  -- Execute all registered callbacks registered with Secretary
  for i,callback in pairs(Secretary.callbacks[eventType]) do
    
    -- Double-check that callback is real
    if callback then
      
      -- Use xpcall to prevent errors from destroying everything
      local success, errmessage = xpcall(
        function() return callback(unpack(arg)) end,
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
