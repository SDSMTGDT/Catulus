require "Room"

function buildLevelFromFile(filename)
  assert(type(filename) == "string", "Unexpected argument type expected")
   
  --local file = love.filesystem.newFile(love.filesystem.getSourceBaseDirectory().."/"..love.filesystem.getIdentity().."/levels/"..filename )
  
  local file = love.filesystem.newFile( "levels/" .. filename )
  
  local width = 0
  local height = 0
  local map = {}
  local line = {}
  local room = Room()
  local character
  
  
  
  file:open( "r" )

  for line in file:lines( ) do
    if i == 1 then
	  width = tonumber( line )
	  i = i + 1
	elseif i == 2 then
	  height = tonumber( line )
	  i = i + 1
	else
      break
    end
  end	
  
  i = 1
  
  for line in file:lines( ) do
    if( i <= 2 ) then
	  i = i + 1
	elseif( i <= height + 2 ) then
	  map[i-2] = {}
	  for j = 1, width do
	    character = string.sub( line, j, j )
	    map[i-2][j] = character
	  end
	  i = i + 1
	end
  end
  
  
--  for i = 1, height do
--    map[i] = {}
--    for j = 1, width do
--      map[i][j] = tonumber( file:read(1) )
--    end
--    file:read()
--  end
  
  file:close( )
  
  -- Build the level
  love.window.setMode( width * 16, height * 16, {resizable=true} )
  room:setDimensions(width * 16, height * 16)
  
  for i = 1, height do
    for j = 1, width do
      
      -- Create element, add to room
      if (map[i][j] == " ") then
        
        -- Do nothing, blank space
        
      elseif (map[i][j] == "B") then
        
        local k = i
		local v = j
		local validRow = true
		local checkWidth = 0
		local bWidth = 0
		local bHeight = 0
		
        -- Expand block horizontally
        while map[i][v] == "B" and v <= width do
          bWidth = bWidth + 1
          v = v + 1
        end
        
        -- Expand block vertically
        v = j
        while validRow == true and k <= height do
          bHeight = bHeight + 1
          
          for v = j, j+bWidth-1 do
            map[k][v] = "b"
          end
          
          -- Check next row
          k = k + 1
          if k <= height then
            for v = j, j+bWidth-1 do
              if map[k][v] ~= "B" then
                validRow = false
                break
              end
            end
          end
        end
        
        -- Create block with expanded dimensions
        -- Note: j-1 and i-1 are positions (i & j are 1 indexed)
        table.insert(room.objects, Block( (j-1) * 16, (i-1) * 16, bWidth * 16, bHeight * 16 ))
		
        -- #DebugTime!!
        print("Created block at ("..j..","..i.."), dimensions "..(bWidth).."x"..(bHeight))
        
      elseif (map[i][j] == "P") then
        
        -- Depends on a player actually existing
        player:setPosition( (j-1) * 16, (i-1) * 16 )
        player:setVelocity( 0, 0 )
        
      elseif (map[i][j] == "E") then
        
        -- Enemy spawn point
        
      end
      
    end
  end
  
  return room
end
