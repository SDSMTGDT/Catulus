
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
    return err.."\n"..debug.traceback() 
  end
end
