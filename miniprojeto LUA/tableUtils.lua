local table = require 'table'
local tableUtils = {}

function tableUtils.reverse(t)
  local rev = {}
  for k, v in pairs(t) do
    rev[v] = k
  end
  return rev
end

function tableUtils.merge(dest, t)
  for k, v in pairs(t) do
    dest[k] = v
  end
end

function tableUtils.copy(t, repeated)
  repeated = repeated or {}
  if type(t) ~= 'table' then
    return t
  end
  if repeated[t] then
    return repeated[t]
  end
  local copy = setmetatable({}, getmetatable(t))
  repeated[t] = copy
  for k, v in pairs(t) do
    copy[tableUtils.copy(k, repeated)] = tableUtils.copy(v, repeated)
  end
  return copy
end

function tableUtils.copyInstance(t)
  if type(t) ~= 'table' then
    return t
  end
  local prototype = t.__proto
  t.__proto = nil
  local copy = tableUtils.copy(t)
  t.__proto = prototype
  copy.__proto = prototype
  return copy
end

return tableUtils