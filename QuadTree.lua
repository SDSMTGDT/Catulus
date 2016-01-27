require "common/class"
require "common/functions"

QuadTree = buildClass()

-- 
-- QuadTree constructor
--
function QuadTree:_init( lvl, top, right, bottom, left )
  self.maxObjects = 10
  self.maxLevels = 5
  
  self.level = lvl
  self.objects = {}
  self.count = 0

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
  self.objects = {}
  
  -- Recursively clear nodes
  for i = 1, 4 do
    self.nodes[i] = nil
  end
end

--
-- QuadTree:isLeaf
--
function QuadTree:isLeaf( )
  return self.nodes[1] == nil and self.nodes[2] == nil and self.nodes[3] == nil and self.nodes[4] == nil
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
-- QuadTree::getSize
--
function QuadTree:getSize( )
  
  -- Add number of objects at current node
  local count = self.count
  
  -- Recursively count as well
  for _,subnode in ipairs(self.nodes) do
    if subnode ~= nil then
      count = count + subnode:getSize()
    end
  end
  
  return count
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
-- QuadTree:getFullIndex
--
function QuadTree:getFullIndex( top, right, bottom, left )
  
  -- Find subnode
  local i = self:getIndex(top, right, bottom, left)
  
  -- Recursively get full index, return as string
  if i ~= 0 and self.nodes[i] ~= nil then
    return i..(self.nodes[i]:getFullIndex(top, right, bottom, left))
  else
    return ""
  end
end

--
-- QuadTree:insert
--
function QuadTree:insert( object, top, right, bottom, left )
  
  -- Verify parameters
  assertType(object, "object", PhysObject)
  
  -- Optional arguments
  if left == nil then
    top, right, bottom, left = object:getBoundingBox()
  end
  
  -- Determine if table needs to be split
  if self.count >= self.maxObjects and self.level < self.maxLevels and self:isLeaf() then
    
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
        self.count = self.count - 1
      else
        -- Object remains in current
        i = i + 1
      end
    end
    
    -- Do the same for objects stored in buckets
    for class,objects in pairs(self.objects) do
      if type(class) == "table" then

        local i = 1
        while i <= table.getn(objects) do

          -- Figure out what child object belongs in
          top, right, bottom, left = objects[i]:getBoundingBox()
          local index = self:getIndex(top, right, bottom, left)

          if index ~= 0 then
            -- Insert object into child, delete from self
            self.nodes[index]:insert(objects[i])
            table.remove(objects, i)
            self.count = self.count - 1
          else
            -- Object remains in current
            i = i + 1
          end
        end

        -- Delete bucket if no objects remain
        if i == 1 then
          self.objects[class] = nil
        end
      end
    end
  end
  

  -- Find subnode object belongs in
  local index = self:getIndex(top, right, bottom, left)

  -- Insert into subnode, return
  if index ~= 0 and self.nodes[index] ~= nil then
    return index .. self.nodes[index]:insert(object, top, right, bottom, left)
  
  -- If not fitting in subnode, insert into current node, return
  -- Insert into appropriate bucket
  else
    local class = object:getClass()
    if class ~= nil then
      if self.objects[class] == nil then self.objects[class] = {} end
      table.insert(self.objects[class], object)
    else
      table.insert(self.objects, object)
    end
    self.count = self.count + 1
    return ""
  end
end

--
-- QuadTree:remove
--
function QuadTree:remove( object, path )
  if path == nil or path:len()==0 then
    
    -- Determine object's class
    local class = object:getClass()
    
    if class == nil then
      
      -- Remove from generic bucket
      for i,o in ipairs(self.objects) do
        if o == object then
          table.remove(self.objects, i)
          self.count = self.count - 1
          return true
        end
      end
    else
      
      -- Search for and remove from in class specific bucket
      if self.objects[class] ~= nil then
        for i,o in ipairs(self.objects[class]) do
          if o == object then
            table.remove(self.objects[class], i)
            self.count = self.count - 1
            return true
          end
        end
      end
    end
    
    -- If not found, remove from subnodes
    for k in pairs(self.nodes) do
      if self.nodes[k]:remove(object) == true then
        return true
      end
    end
    
    -- Not found, return false
    return false
  else
    
    -- Path supplied, just blindly follow path
    local t = tonumber(path:sub(1,1))
    if self.nodes[t] ~= nil then
      return self.nodes[t]:remove(object, path:sub(2))
    else
      return false
    end
  end
end

--
-- QuadTree:retrieve
--
function QuadTree:retrieve( list, top, right, bottom, left, ... )
  local arg = {...}
  
  -- Short-circuit if bounds are outside of this tree
  if self.top >= bottom or self.left >= right or left >= self.right or top >= self.bottom then
    return list
  end
  
  -- Recurse into subnodes
  for _,subnode in ipairs(self.nodes) do
    subnode:retrieve(list, top, right, bottom, left, ...)
  end
  
  -- Add all objects at current node that match type parameters
  for key,val in pairs(self.objects) do
    
    -- Add objects in generic bucket if no class types are supplied
    if type(key) == "number" then
      if table.getn(arg) == 0 then
        table.insert(list, val)
      end
    
    -- Add objects from matching buckets, note we must scan buckets themselves
    elseif type(key) == "table" then
      
      -- Insert all objects from all buckets if no class filters are specified
      if table.getn(arg) == 0 then
        for _,obj in ipairs(val) do
          table.insert(list, obj)
        end
      else
        
        -- Scan buckets for matching buckets
        for _,a in ipairs(arg) do
          if instanceOf(key, a) then
            for _,obj in ipairs(val) do
              table.insert(list, obj)
            end
            break
          end
        end
      end
    end
  end
  
  return list
end

--
-- QuadTree:draw
--
function QuadTree:draw( )
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("line", self.left, self.top, self.right - self.left, self.bottom - self.top)
  for _,subnode in ipairs(self.nodes) do
    subnode:draw()
  end
end
