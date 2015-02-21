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
function QuadTree: _init( lvl, top, right, bottom, left )

  self.maxObjects = 10
  self.maxLevels = 5
  
  self.level = lvl
  self.objects = {}

  self.nodes = {nil, nil, nil, nil}
  
  self.top = top
  self.right = right
  self.bottom = bottom
  self.left = left
  
end

--
-- QuadTree:clear
--
function QuadTree:clear( )
  
  -- Clear objects list
  for i in pairs(objects) do
    objects[i] = nil
  end
  
  -- Recursively clear nodes
  for i = 1, 4 do
    if self.nodes[i] ~= nil then
      self.nodes[i]:clear()
      self.nodes[i] = nil
    end    
  end
end

--
-- QuadTree:isLeaf
--
function QuadTree:isLeaf( )

  for i = 1, 4 do
    if self.nodes[i] ~= nil then
      return false
    end
  end
  return true

end

--
-- QuadTree:split
--
function QuadTree:split( )

  local subWidth = (self.right + self.left) / 2
  local subHeight = (self.top + self.bottom) / 2
  
  self.nodes[1] = QuadTree( self.level+1, self.top, self.right, subHeight, subWidth )
  self.nodes[2] = QuadTree( self.level+1, self.top, subWidth, subHeight, self.left )
  self.nodes[3] = QuadTree( self.level+1, subHeight, subWidth, self.bottom, self.left )
  self.nodes[4] = QuadTree( self.level+1, subHeight, self.right, self.bottom, subWidth )

end

--
-- QuadTree:getIndex
--
function QuadTree:getIndex( top, right, bottom, left )

  local index = 0
  local subWidth = (self.right + self.left) / 2
  local subHeight = (self.top + self.bottom) / 2
  
  -- Check upper half
  if top >= self.top and bottom < subHeight then
    
    
    -- Check right side (Q I)
    if left >= subWidth and right < self.right then
      index = 1
      
    -- Check left side (Q II)
    elseif left >= self.left and right < subWidth then
      index = 2
    end
    
  -- Check lower half
  elseif top >= subHeight and bottom < self.bottom then
    
    -- Check left side (Q III)
    if left >= self.left and right < subWidth then
      index = 3
      
    -- Check right side (Q IV)
    elseif left >= subWidth and right < self.right then
      index = 4
    end
  end
  
  return index
end

--
-- QuadTree:insert
--
function QuadTree:insert( object, top, right, bottom, left )
  
  -- Optional arguments
  if left == nil then
    top, right, bottom, left = object:getBoundingBox()
  end
  
  -- Check for recursive insertion
  if self:isLeaf() == false then
    
    -- Find subnode object belongs in
    local index = self:getIndex(top, right, bottom, left)
    
    -- Insert into subnode, return
    if index ~= 0 then
      self.nodes[index]:insert(object, top, right, bottom, left)
      return
    
    -- If not fitting in subnode, insert into current node, return
    else
      table.insert(self.objects, object)
      return
    end
  
  else      -- Is leaf, might have to split
  
    -- Doesn't belong in subnode, insert into current node
    table.insert(self.objects, object)
    
    -- Split if necessary, possible, and not done yet
    if table.getn(self.objects) > self.maxObjects and self.level < self.maxLevels then
      
      
      -- Split if not splitted so far
      self:split()
      
      -- Distribute objects into child nodes
      local i = 1
      while i <= table.getn(self.objects) do
        
        -- Figure out what child object belongs in
        top, right, bottom, left = self.objects[i]:getBoundingBox()
        local index = self:getIndex(top, right, bottom, left)
        
        if index ~= 0 then
          -- Insert object into child, delete from self
          self.nodes[index]:insert(self.objects[i])
          table.remove(self.objects, i)
        else
          -- Object remains in current
          i = i + 1
        end
      end
    end
  end
end

--
-- QuadTree:retrieve
--
function QuadTree:retrieve( list, top, right, bottom, left )
  
  local index = self:getIndex(top, right, bottom, left)
  
  if index ~= -1 and self:isLeaf() == false then
    self.nodes[index]:retrieve(list, top, right, bottom, left)
  end
  
  for o in pairs(self.objects) do
    table.insert(list, o)
  end
  
  return list
  
end

function QuadTree:draw( )
  love.graphics.rectangle("line", self.left, self.top, self.right - self.left, self.bottom - self.top)
  for i in pairs(self.nodes) do
    if i ~= nil then
      self.nodes[i]:draw()
    end
  end
end
