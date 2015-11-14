

Animation = {}
Animation.__index = Animation


--FLUFF--
setmetatable(Animation, {
      __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  }
)


--Constructor--

function Animation:_init( )

  self.frames = {}	

end

function Animation:load( filename )
  local i = 0
  local line
  
  file = io.open("gfx/"..filename, "r")
  while( line = file:read() )
    self.frames[i] = love.graphics.newImage( "gfx/"..line )
	i = i + 1
  end
  
  file:close()
 
end

function Animation:update( )



end