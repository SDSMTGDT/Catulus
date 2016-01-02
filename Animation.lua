

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
  self.xScale = 1
  self.yScale = 1  
  self.framecount = 1
  self.framequeue = 1
  self.counter = 1
  self.rate = 2
end

function Animation:load( filename )
  local i = 1
  local line = {}

  --Read animation file to find png's for a specific animation
  file = love.filesystem.newFile("gfx/"..filename)
  file:open("r")

  for line in file:lines() do
    print( line )
	if( line ~= nil ) then
      self.frames[i] = love.graphics.newImage( "gfx/"..line )
	  i = i + 1
	  self.framecount = self.framecount + 1
	end
  end
  
  file:close()
 
end

function Animation:update(  )

  
  if( self.counter >= self.rate ) then
    self.framequeue =  self.framequeue + 1
    self.counter = 0
  end
  
  if (self.framequeue == self.framecount) then
    self.framequeue = 1
  end
  
  self.counter = self.counter + 1
  
end

function Animation:draw( x, y, origin )

  love.graphics.draw( self.frames[self.framequeue], x, y, 0, self.xScale, self.yScale, origin )

end