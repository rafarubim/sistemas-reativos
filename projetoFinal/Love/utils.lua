local utils = {}

function utils.spreadValues(first, last, amount)
  local increment
  local current
  if amount > 1 then
    increment = (last - first) / (amount - 1)
    current = first - increment
  else
    increment = 0
    current = first + (last - first) / 2
  end
  local inx = 0
  return function()
    current = current + increment
    inx = inx + 1
    if inx > amount then
      return
    end
    return current, inx
  end
end

function utils.numberToLetter(number)
  return string.char(number + string.byte('a') - 1)
end

return utils