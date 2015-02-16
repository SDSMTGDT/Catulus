-- Required fluff for classes
QuadTree = {}
QuadTree.__index = QuadTree


setmetatable(QuadTree, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)

-- 
-- QuadTree constructor
--
function QuadTree: _init( lvl, posX, posY, width, height )

  self.maxObjects = 10
  self.maxLevels = 5
  
  self.level = lvl
  self.objects = {}

  self.quadNodes = {}
  
  self.widthX = width
  self.heightY = height
  
  self.positionX = posX
  self.positionY = posY
  
end

--
-- QuadTree:clear
--
function QuadTree:clear( )
  
  objects.clear()
  
  for i = 0, 3 do
    if self.quadNodes[i] ~= nil
      self.quadNodes[i].clear
      self.quadNodes[i] = nil
    end    
  end
end

--
-- QuadTree:isLeaf
--
function QuadTree:isLeaf( )

  for i = 0, 3 do
    if self.quadNodes[i] ~= nil
      return true
    end
  end
  return false

end

--
-- QuadTree:split
--
function QuadTree:split()

  local subWidth = self.width / 2
  local subHeight = self.height / 2
  
  local x = self.positionX
  local y = self.positionY
  
  quadNodes[0] = QuadTree( lvl+1, x + subWidth, y , subWidth, subHeight )
  quadNodes[1] = QuadTree( lvl+1, x, y, subWidth, subHeight )
  quadNodes[2] = QuadTree( lvl+1, x, y + subHeight, subWidth, y + subHeight )
  quadNodes[3] = QuadTree( lvl+1, x + subWidth, y + subHeight, subWidth, subHeight )

end

--
-- QuadTree:getIndex
--
function QuadTree:getIndex()



end
