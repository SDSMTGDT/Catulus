require "common/functions"

function buildEnum(enum)
  local n = 1
  while enum[n] ~= nil do
    enum[enum[n]] = n
    n = n + 1
  end
  enum.n = n - 1
  
  enum.values = function()
    local i = 0
    return function()
      i = i + 1
      if i <= enum.n then return i end
    end
  end
  
  enum.fromId = function(id)
    assertType(id, "id", "number")
    if id > enum.n or id < 1 then
      return nil
    else
      return id
    end
  end
  
end
