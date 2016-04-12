require "common/class"
require "Spawn"
require "Enemy"


levelScript = {}


function Level(levelID)
  level = levelScript[levelID]()
  return level
end


require "levels/level1"