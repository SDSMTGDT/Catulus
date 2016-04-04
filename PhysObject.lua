require "common/class"
require "Entity"
require "Secretary"

--
-- PhysObject
--
-- Class designed to supply basic physics functionality for objects that exist
-- in a physics system. This class provides basic coordinate functionality,
-- sizing, velocity, and acceleration. All variables can be get and set as
-- needed.
--
PhysObject = buildClass(Entity)

---------------------------------------
-- BEGIN PhysObject CLASS DEFINITION --
---------------------------------------

--
-- Constructor
--
-- Initializes data members, such as size dimensions, position, velocity, and
-- acceleration information.
--
function PhysObject:_init( )
  Entity._init(self)
  
  -- Declare object properties
  self.size = {}
  self.position = {}
  self.velocity = {}
  self.acceleration = {}
  
  -- Initialize Size
  self.size.width = 0
  self.size.height = 0
  self.size.depth = 0
  
  -- Initialize location
  self.position.x = 0
  self.position.y = 0
  self.position.z = 0
  
  -- Initialize velocity
  self.velocity.x = 0
  self.velocity.y = 0
  self.velocity.z = 0
  
  -- Initialize acceleration
  self.acceleration.x = 0
  self.acceleration.y = 0
  self.acceleration.z = 0
end



--
-- Registers this object to handle `EventType.PHYSICS` callbacks. Also registers
-- self as PhysObject with the provided secretary, allowing for location
-- tracking for collision events.
--
-- See Entity.registerWithSecretary()
--
function PhysObject:registerWithSecretary(secretary)
  Entity.registerWithSecretary(self, secretary)
  
  -- Register for collisions and event callbacks
  secretary:registerPhysObject(self)
  secretary:registerEventListener(self, self.update, EventType.PHYSICS)
  
  -- Only register for drawing if the `draw` function has been overridden
  if self.draw ~= PhysObject.draw then
    secretary:registerEventListener(self, self.draw, EventType.DRAW)
  end
  
  return self
end



--
-- Sets this object's dimensions in pixels. All dimensions are relative to the
-- object's origin point, which can be visualized as being located in the back
-- bottom left corner of the object.
--
-- Parameter w: The size along the x-axis (width) of this object.
-- Parameter h: The size along the y-axis (height) of this object.
-- Parameter d: The size along the z-axis (depth) of this object. Optional.
--
function PhysObject:setSize( w, h, d )
  
  -- Handle optional argument d
  d = d or self.size.depth
  
  -- Set size
  self.size.width = w
  self.size.height = h
  self.size.depth = d
end



--
-- Gets the dimensions of this object as set using the `setSize()` function.
-- Returns the width, height, and depth of the object respectively in pixels.
--
-- Return w: The size along the x-axis (width) of this object.
-- Return h: The size along the y-axis (height) of this object.
-- Return d: The size along the z-axis (depth) of this object.
--
function PhysObject:getSize()
  return self.size.width, self.size.height, self.size.depth
end



--
-- Calculates and returns the bounding box of this object. Allows bounding box
-- to be offset by provided pixel values.
--
-- Parameter x: The number of pixels along the x-axis to offset the bounding box
--              by. Positive values shift the box right, negative values shift
--              the box left. Optional, defaults to `0`.
-- Parameter y: The number of pixels along the y-axis to offset the bounding box
--              by. Positive values shift the box up, negative values shift the
--              box down. Optional, defaults to `0`.
-- Parameter z: The number of pixels along the z-axis to offset the bounding box
--              by. Positive values shift the box forward, negative values shift
--              the box back. Optional, defaults to `0`.
--
-- Return top: The greatest value along the y-axis the object reaches, offset by
--             the provided `y` parameter.
-- Return right: The greatest value along the x-axis the object reaches, offset
--               by the provided `x` parameter.
-- Return bottom: The smallest value along the -axis the object reaches, offset
--                by the provided `y` parameter.
-- Return left: The smallest value along the x-axis the object reaches, offset
--              by the provided `x` parameter.
-- Return back: The smallest value along the z-axis the object reaches, offset
--              by the provided `z` parameter.
-- Return front: The greatest value along the z-axis the object reaches, offset
--               by the provided `z` parameter.
--
function PhysObject:getBoundingBox( x, y, z )
  
  -- Assign default values
  x = x or 0
  y = y or 0
  z = z or 0
  
  -- Return bounding box with offsets
  return self.position.y + y,
    self.position.x + x + self.size.width,
    self.position.y + y + self.size.height,
    self.position.x + x,
    self.position.z + z,
    self.position.z + z + self.size.depth
end



--
-- Sets the physical coordinates of the object's origin point to the provided
-- parameters.
--
-- Parameter x: The x-coordinate to move the object to.
-- Parameter y: The y-coordinate to move the object to.
-- Parameter z: The z-coordinate to move the object to. Optional.
--
function PhysObject:setPosition( x, y, z )
  
  -- Handle optional argument z
  z = z or self.position.z
  
  -- Set coordinates
  self.position.x = x
  self.position.y = y
  self.position.z = z
end



--
-- Gets the coordinates of the object's origin point.
--
-- The origin point can be visualized as being located at the object's back-
-- bottom- left-most point.
--
-- Return x: The location of the object's origin point along the x-axis.
-- Return y: The location of the object's origin point along the y-axis.
-- Return z: The location of the object's origin point along the z-axis.
--
function PhysObject:getPosition( )
  return self.position.x, self.position.y, self.position.z
end



--
-- Sets the object's velocity vector to the provided parameters, measured in
-- pixels-per-frame.
--
-- Parameter x: The value to set the object's velocity along the x-axis to.
-- Parameter y: The value to set the object's velocity along the y-axis to.
-- Parameter z: The value to set the object's velocity along the z-axis to.
--              Optional.
--
function PhysObject:setVelocity( x, y, z )
  
  -- Handle optional argument z
  z = z or self.velocity.z
  
  -- Set velocity vector
  self.velocity.x = x
  self.velocity.y = y
  self.velocity.z = z
end



--
-- Gets the object's velocity vector in pixels-per-frame.
--
-- Return x: The object's velocity along the x-axis.
-- Return y: The object's velocity along the y-axis.
-- Return z: The object's velocity along the z-axis.
--
function PhysObject:getVelocity( )
  return self.velocity.x, self.velocity.y, self.velocity.z
end



--
-- Sets the object's acceleration vector to the provided parameters, measured in
-- pixels-per-frame-per-frame.
--
-- Parameter x: The value to set the object's acceleration along the x-axis to.
-- Parameter y: The value to set the object's acceleration along the y-axis to.
-- Parameter z: The value to set the object's acceleration along the z-axis to.
--              Optional.
--
function PhysObject:setAcceleration( x, y, z )
  -- Handle optional argument z
  z = z or self.acceleration.z
  
  -- Set acceleration vector
  self.acceleration.x = x
  self.acceleration.y = y
  self.acceleration.z = z
end



--
-- Gets the object's acceleration vector in pixels-per-frame-per-frame.
-- 
-- Return x: The object's acceleration along the x-axis.
-- Return y: The object's acceleration along the y-axis.
-- Return z: The object's acceleration along the z-axis.
--
function PhysObject:getAcceleration( )
  return self.acceleration.x, self.acceleration.y, self.acceleration.z
end



--
-- Updates the object's physical state for a single frame, adjusting location
-- and velocity as appropriate and notifying secretary of any change in
-- position.
--
function PhysObject:update( )
  -- Update velocity
  self.velocity.x = self.velocity.x + self.acceleration.x
  self.velocity.y = self.velocity.y + self.acceleration.y
  self.velocity.z = self.velocity.z + self.acceleration.z
  
  -- Update position
  self.position.x = self.position.x + self.velocity.x
  self.position.y = self.position.y + self.velocity.y
  self.position.z = self.position.z + self.velocity.z
  
  self:getSecretary():updateObject(self)
end



--
-- Method to determine if the current object collides with the provided bounding
-- box. Note: this function simply checks for bounding box overlap only! It does
-- not guarantee that objects with collision masks that are not axis-aligned
-- bounding boxes collide.
--
-- Return: `true` if this object's axis-aligned bounding box overlaps in any way
--         with the provided bounding box.
--
function PhysObject:collidesWith( t2, r2, b2, l2 )
  local t1, r1, b1, l1 = self:getBoundingBox()
  
  return (b1 > t2 and t1 < b2 and r1 > l2 and l1 < r2)
end



--
-- Method for rendering this object to the display. Will automatically be
-- registered with the Secretary if overridden.
-- 
function PhysObject:draw()
  -- This method exists soley to be overridden. Will not be registered with a
  -- secretary unless overridden or explicitly called.
end
