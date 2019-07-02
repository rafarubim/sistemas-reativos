local tableUtils = require 'tableUtils'

local Class = {}

local weakMetatable = { __mode = 'k' }

function Class:extended(extends)
  extends = extends or {}
  local isNotMetatable = not rawget(self, '__index')
  if isNotMetatable then
    rawset(self, "__index", function(t, k)
      rawset(t, k, tableUtils.copyInstance(self[k]))
      return rawget(t, k)
    end)
  end
  setmetatable(extends, self)
  rawset(extends, '__proto', self)
  local instancesTable = setmetatable({}, weakMetatable)
  rawset(extends, '__instances', instancesTable)
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
  self.__instances[#self.__instances+1] = instance
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