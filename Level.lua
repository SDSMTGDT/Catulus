levelScript = {}


function Level(levelID)
  level = levelScript[levelID]()
  return level
end


require "levels/level1"