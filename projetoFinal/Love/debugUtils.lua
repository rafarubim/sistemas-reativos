local debugUtils = {}

local printRaw = function(x)
  if type(x) == 'table' then
    io.stdout:write("[table]")
  elseif type(x) == 'function' then
    io.stdout:write("[function]")
  elseif type(x) == 'userdata' then
    io.stdout:write("[userdata]")
  elseif type(x) == 'boolean' then
    io.stdout:write("[boolean]")
  else
    io.stdout:write(x)
  end
end

function debugUtils.printTable(t, shallow, repeated, spaces)
  shallow = shallow or false
  repeated = repeated or {}
  spaces = spaces or 1
  repeated[t] = true
  printRaw(t)
  printRaw(" {\n")
  for k, v in pairs(t) do
    for i = 1, spaces do
      printRaw("  ")
    end
    if type(k) == "table" and not repeated[k] and not shallow then
      debugUtils.printTable(k, shallow, repeated, spaces+1)
    else
      printRaw(k)
    end
    printRaw(": ")
    if type(v) == "table" and not repeated[v] and not shallow then
      debugUtils.printTable(v, shallow, repeated, spaces+1)
    else
      printRaw(v)
    end
    printRaw(",\n")
  end
  for i = 1, spaces-1 do
    printRaw("  ")
  end
  printRaw("}")
  if spaces == 1 then
    printRaw("\n")
  end
end

return debugUtils