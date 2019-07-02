local listUtils = {}

function listUtils.filter(lst, filter)
  local newLst = {}
  for inx, elem in ipairs(lst) do
    if filter(elem, inx) then
      newLst[#newLst+1] = elem
    end
  end
  return newLst
end

function listUtils.first(lst, first)
  for inx, elem in ipairs(lst) do
    if type(first) ~= 'function' and elem == first then
      return elem, inx
    elseif type(first) == 'function' and first(elem, inx) then
      return elem, inx
    end
  end
  return nil
end

return listUtils