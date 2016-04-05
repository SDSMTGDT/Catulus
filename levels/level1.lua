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
  room:buildBlock( 0, 32, width * 16 , 32 )
  --build a ceiling
  room:buildBlock( 0, height * 16, width * 16, 16 )
  --build left wall
  room:buildBlock( 32, 16, 32, height * 16 )
  --build right wall
  room:buildBlock( 16 * (width + 1), 16, 16, height * 16 )
  
  
  --Add stepping blocks
  ---------------------------------------------------------------------
  room:buildBlock( 16 * 16, 5 * 16, 5 * 16, 32)
  
  
  --Add Enemy spawns
  ---------------------------------------------------------------------
  room:addSpawn(Spawn( 5 * 16, 5 * 16, Enemy))
  
  
  
  
  return room
end