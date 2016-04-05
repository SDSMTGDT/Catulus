require "common/class"
require "Spawn"


levelScript = {}


function Level(levelID)
  level = levelScript[levelID]()
  return level
end


require "levels/level1"