require "enum"

-- Enum
-- Defines depth for drawing layers
DrawLayer = {
  "BACKGROUND",       -- wallpapers, scenery
  "BACKGROUND_PROPS", -- props, behind actors
  "MAIN",             -- where all the action happens
  "SPOTLIGHT",        -- only for the most important actors
  "FOREGROUND_PROPS", -- in-your-face props
  "FOREGROUND",       -- more decoration
  "UI",               -- only the most important things
}

buildEnum(DrawLayer)
