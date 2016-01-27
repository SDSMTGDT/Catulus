
--Test if argument 1 is an instance of argument 2
--Returns true or false

function instanceOf( object, class )
  while object ~= nil and class ~= nil do
    if object == class then
      return true
    else
      --Compares all parent classes
      object = getmetatable(object)
    end
  end
  --No match found
  return false
end

-- Function for catching errors and returning the traceback (AKA stack trace)
function catchError( err )
  if debug then
    return err..debug.traceback().."\n"
  end
end

-- Convenience function for type assertions
function assertType( value, name, t )
  if (type(t) == "table") then
    assertType(value, name, "table")
    assert(instanceOf(value, t), "Unexpected type for "..name..": Object not instance of expected type")
  elseif (type(t) == "string") then
    assert(type(value) == t, "Unexpected type for "..name..": "..t.." expected, "..type(object).." received")
  end
end
