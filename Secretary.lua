require "QuadTree"

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

function Secretary.registerObject(object)
  
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
