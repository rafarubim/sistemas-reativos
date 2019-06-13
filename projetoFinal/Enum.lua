local tableUtils = require 'tableUtils'

local Enum = {}

function Enum:create()
  return {
    setValues = function(self, values)
      for k, v in pairs(values) do
        if self.constructor then
          self:constructor(v)
        end
        self[v] = k
      end
      self.__reversed = values
    end,
    values = function(self)
      return pairs(self.__reversed)
    end,
    names = function(self)
      local rev = tableUtils.reverse(self.__reversed)
      return pairs(rev)
    end,
    getName = function(self, v)
      return self.__reversed[v]
    end
  }
end

return Enum