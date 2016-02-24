require "common/class"
require "Secretary"

Entity = buildClass()

--------------------------------------------------------------------------------
--                                Entity Class                                --
--------------------------------------------------------------------------------

function Entity:_init()
  
  -- Assigned secretary object
  self.secretary = nil
end

function Entity:registerWithSecretary(secretary)
  
  -- Ensure secretary is of correct type
  assertType(secretary, "secretary", Secretary)
  
  -- Make sure we're not already registered with a secretary
  if self.secretary ~= nil then
    self:deregisterWithSecretary()
  end
  
  -- Store reference to secretary we are registered with
  self.secretary = secretary
  
  return self
end

function Entity:deregisterWithSecretary()
  
  -- Remove all record of self from current secretary
  if self.secretary ~= nil then
    self.secretary:remove(self)
  end
  
  -- Forget registered secretary
  self.secretary = nil
end

function Entity:getSecretary()
  return self.secretary
end

function Entity:destroy()
  self:deregisterWithSecretary()
end
