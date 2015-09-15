
function buildLevelFromFile(filename)
  assert(type(filename) == "string", "Unexpected argument type expected")
  
  local file = io.open(love.filesystem.getSourceBaseDirectory().."/"..love.filesystem.getIdentity().."/levels/"..filename, "r")
  
  local width = 0
  local height = 0
  
  local map = {}
  
  width = tonumber(file:read())
  height = tonumber(file:read())
  
  for i = 1, height do
    map[i] = {}
    for j = 1, width do
      map[i][j] = file:read(1)
    end
    file:read()
  end
  
  file:close(file)
  
  -- Build the level
  love.window.setMode( width * 16, height * 16, {} )
  
  for i = 1, height do
    for j = 1, width do
      
      -- Create element, add to room
      if (map[i][j] == " ") then
        
        -- Do nothing, blank space
        
      elseif (map[i][j] == "B") then
	  --[[
        local k = i
		local v = j
		local firstPass = true
		local checkWidth = 0
		local bWidth = 0
		local bHeight = 0
		-- Loop
		while map[k][j] == "B" and k < height do
		  if checkWidth == bWidth then
		    bHeight = bHeight + 16
			if firstPass == false then
			  while map[k-1][v] == "B" do
			    map[k-1][v] = "b"
			    v = v + 1
			  end
			end
			v = j
		  else
			bWidth = 0
			bHeight = 0
			firstPass = true
			--k = height
		  end
		  
		  checkWidth = 0
		  
		  while map[k][v] == "B" and k ~= height do 
		    if firstPass == true then
			  bWidth = bWidth + 16
			  map[k][v] = "b"
			end
			
			checkWidth = checkWidth + 16
			v = v + 1
		  end
		  
		  firstPass = false
		  v = j
		  k = k + 1
		end
	  ]]--
	  
        Block( (j-1) * 16, (i-1) * 16, 16, 16 )
		
      elseif (map[i][j] == "P") then
        
        local player = Player()
        player:setPosition( (j-1) * 16, (i-1) * 16 )
        
      elseif (map[i][j] == "E") then
        
        -- Enemy spawn point
        
      end
      
    end
  end
  
  local room = {}
  room.width = width * 16
  room.height = height * 16
  
  return room
end
