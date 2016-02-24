require "common/class"
require "Secretary"

Entity = buildClass()

--------------------------------------------------------------------------------
--                                Entity Class                                --
--------------------------------------------------------------------------------



--
-- `Entity` constructor. Initializes data members.
--
function Entity:_init()
  Object:_init(self)
  
  -- Assigned secretary object
  self.secretary = nil
end



--
-- Registers this entity with a `Secretary` object. This will also deregister this
-- object from any previously registered `Secretary`.
--
-- - param secretary Secretary: The `Secretary` object to register with.
--
-- - return: This same object so that this method can be called inline and
--           without affecting normal function.
--
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



--
-- Unregisters this object from the `Secretary` object it had been previously
-- registered with using the `registerWithSecretary()` method, if any.
--
function Entity:deregisterWithSecretary()
  
  -- Remove all record of self from current secretary
  if self.secretary ~= nil then
    self.secretary:remove(self)
  end
  
  -- Forget registered secretary
  self.secretary = nil
end



--
-- Gets the `Secretary` object with which this object has been previously
-- registered using a call to the `registerWithSecretary()` method.
--
-- - return: The `Secretary` object that this object is registered with or `nil`
--           if this object has not been registered or if
--           `deregisterWithSecretary()` has been more recently called.
--
function Entity:getSecretary()
  return self.secretary
end



--
-- Performs any necessary self-destruction steps, including deregistering this
-- object from any known `Secretary` objects.
--
function Entity:destroy()
  self:deregisterWithSecretary()
end
