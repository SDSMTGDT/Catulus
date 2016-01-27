require "class"

Animation = buildClass()


-- Cached images
Animation.cache = {}


--Constructor--

function Animation:_init( filename )

  self.frames = {}
  self.xScale = 1
  self.yScale = 1  
  self.framecount = 0
  self.framequeue = 1
  self.counter = 1
  self.rate = 2
  
  if Animation.cache[filename] == nil then
    Animation.load(filename)
  end
  
  for i,frame in pairs(Animation.cache[filename]) do
    self.frames[i] = frame
    self.framecount = self.framecount + 1
  end
  
end

function Animation.load( filename )
  
  Animation.cache[filename] = {}
  local frames = Animation.cache[filename]
  local i = 1
  local line = {}

  --Read animation file to find png's for a specific animation
  file = love.filesystem.newFile("gfx/"..filename..".txt")
  file:open("r")

  for line in file:lines() do
    print( line )
	if( line ~= nil ) then
      frames[i] = love.graphics.newImage( "gfx/"..line )
	  i = i + 1
	end
  end
  
  file:close()
 
end

function Animation:update(  )

  
  if( self.counter >= self.rate ) then
    self.framequeue =  self.framequeue + 1
    self.counter = 0
  end
  
  if (self.framequeue > self.framecount) then
    self.framequeue = 1
  end
  
  self.counter = self.counter + 1
  
end

function Animation:draw( x, y, origin )

  love.graphics.draw( self.frames[self.framequeue], x, y, 0, self.xScale, self.yScale, origin )

end