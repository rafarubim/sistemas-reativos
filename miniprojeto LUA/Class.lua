local tableUtils = require 'tableUtils'

local Class = {}
function Class:extended(extends)
  extends = extends or {}
  rawset(self, "__index", function(t, k)
    rawset(t, k, tableUtils.copyInstance(self[k]))
    return rawget(t, k)
  end)
  setmetatable(extends, self)
  rawset(extends, '__proto', self)
  return extends
end

function Class:constructor()
end

function Class:super(instance, ...)
  local prototype = getmetatable(self)
  prototype.constructor(instance, ...)
end

function Class:new(instance, ...)
  instance = self:extended(instance)
  instance:constructor(...)
  return instance
end

function Class:is(class)
  if not self.__proto then
    return false
  end
  if self.__proto == class then
    return true
  end
  return self.__proto:is(class)
end

return Class