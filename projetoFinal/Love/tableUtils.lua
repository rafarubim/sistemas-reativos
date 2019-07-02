local table = require 'table'
local tableUtils = {}

function tableUtils.reverse(t)
  local rev = {}
  for k, v in pairs(t) do
    rev[v] = k
  end
  return rev
end

function tableUtils.keywiseAnd(dest, t)
  for k, v in pairs(dest) do
    dest[k] = t[k]
  end
end

function tableUtils.merge(dest, t)
  for k, v in pairs(t) do
    dest[k] = v
  end
end

local function deepCopy(t, shallow, repeated)
  shallow = shallow or {}
  repeated = repeated or {}
  if type(t) ~= 'table' then
    return t
  end
  if shallow[t] then
    return t
  end
  if repeated[t] then
    return repeated[t]
  end
  local copy = setmetatable({}, getmetatable(t))
  repeated[t] = copy
  for k, v in pairs(t) do
    copy[deepCopy(k, shallow, repeated)] = deepCopy(v, shallow, repeated)
  end
  return copy
end

function tableUtils.copy(t, shallowLst)
  shallowLst = shallowLst or {}
  local shallow = tableUtils.reverse(shallowLst)
  return deepCopy(t, shallow)
end

function tableUtils.copyInstance(t)
  if type(t) ~= 'table' then
    return t
  end
  return tableUtils.copy(t, { t.__proto })
end

return tableUtils