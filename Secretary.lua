require "QuadTree"

-- Required fluff for classes
require "functions"
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

function Secretary.registerObject(object)
  
  --Check that object is an instance of PhysObject
  if instanceOf( object, PhysObject ) == false then
    return false
  end
  
  -- Make sure object is valid and ID is unset
  if object == nil or object.id ~= nil then
    return false
  end
  
  -- Assign object an ID, add to data structures
  object.id = Secretary.nextId
  Secretary.objects[Secretary.nextId] = object
  
  -- Store full node path
  Secretary.objectNodes[Secretary.nextId] = Secretary.tree:insert(object)
  
  -- Increment ID for next object
  Secretary.nextId = Secretary.nextId + 1
  
  return true
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
  assert( type(object) == "number" or instanceOf( object, PhysObject ), "Invalid parameter type" )
  local id = object
  
  if type(id) == "number" then
    object = Secretary.objects[id]
    assert( object , "Invalid object ID "..id ) 
  else
    id = object:getInstanceId()
  end
  
  Secretary.tree:remove(object, Secretary.objectNodes[id])
  Secretary.objects[id] = nil
  Secretary.objectNodes[id] = nil
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

