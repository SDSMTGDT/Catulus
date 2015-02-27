require "PhysObject"
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

