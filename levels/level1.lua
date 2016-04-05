levelScript["level1"] = function()
  --Room dimensions
  local width = 48
  local height = 36
  --Player spawn location
  local playerSpawn_x = 3 * 16
  local playerSpawn_y = 5 * 16
  
  
  
  --Initilize room
  local room = Room(width, height)
  
  --add a player spawn
  room:addPlayerSpawnPoint(playerSpawn_x, playerSpawn_y)
  
  
  --Box in the room
  ---------------------------------------------------------------------
  --build a floor
  room:buildBlock( 0, (height - 1) * 16, width * 16 , 16 )
  --build a ceiling
  room:buildBlock( 0, 0, width * 16, 16 )
  --build left wall
  room:buildBlock( 0, 16, 16, (height - 2) * 16 )
  --build right wall
  room:buildBlock( (width - 1) * 16, 16, 16, (height - 2) * 16 )
  
  
  --Add stepping blocks
  ---------------------------------------------------------------------
  room:buildBlock( 16 * 16, 5 * 16, 5 * 16, 32)
  room:addObject(PassthroughBlock(20*16, 10*16, 5*16, 16))
  room:addObject(PassthroughBlock(10*16, 10*16, 5*16, 16))
  room:addObject(PassthroughBlock(20*16, 16*16, 5*16, 16))
  room:addObject(PassthroughBlock(10*16, 22*16, 5*16, 16))
  room:addObject(PassthroughBlock(20*16, 28*16, 5*16, 16))
  
  
  --Add moving platforms
  ---------------------------------------------------------------------
  room:addObject(MovingPlatform(24*16, 30*16, 8*16, 24, 24*16, 10*16, 240))
  
  
  --Add Enemy spawns
  ---------------------------------------------------------------------
  
  
  
  
  
  return room
end