local httpServer = {
  routeCbs = {},
  routeParamNames = {}
}

local function response(body, headers)
  body = body or ''
  headers = headers or {}
  local response = ''
  for k, v in pairs(headers) do
    response = response .. k .. ': ' .. v .. '\r\n'
  end
  response = response .. '\r\n'
  if body ~= '' then
	  response = response .. body .. '\r\n'
  end
  return response
end

function httpServer.okResponse(body, headers)
  return 'HTTP/1.1 200 OK\r\n' .. response(body, headers)
end

function httpServer.notFoundResponse(body, headers)
  return 'HTTP/1.1 404 NOT FOUND\r\n' .. response(body, headers)
end

local reqBuff = {}
setmetatable(reqBuff, {__index = function (t, k)

  local newValue = {
    metaData = nil,
    headers = '',
    content = '',
    method = nil,
    path = nil,
    queryString = nil,
    contentLength = nil
  }
  rawset(t, k, newValue)
  return newValue
end })

local function receiver(sck, request)
  --print("Request:")
  --print(request.metaData .. request.headers .. '\r\n' .. request.content)
  
  if not request.method or not request.path then
	  print('Request error')
	  sck:close() 
	  return
  end

  local queryParams = {}
  if request.queryString ~= nil then
    for k, v in string.gmatch(request.queryString, "(%w+)=([^&]+)") do
      queryParams[k] = v
    end
  end

  local routeCb
  local pathParams = {}

  for pathTemplate, cb in pairs(httpServer.routeCbs) do
    local templateRegex = pathTemplate
    templateRegex = string.gsub(templateRegex, '{.-}', '([^/]+)')
    templateRegex = string.gsub(templateRegex, '%*%*', '.+')
    templateRegex = string.gsub(templateRegex, '%*', '[^/]+')
    templateRegex = '^' .. templateRegex .. '$'
    local matches = { string.match(request.path, templateRegex) }
    if #matches > 0 then
      routeCb = cb
      if #httpServer.routeParamNames[pathTemplate] > 0 then -- has path params
        for inx, param in ipairs(matches) do
          pathParams[httpServer.routeParamNames[inx]] = param
        end
      end
      break
    end
  end

  local response

  if routeCb ~= nil then
    local request = {
      body = request.content,
      pathParams = pathParams,
      queryParams = queryParams,
      method = request.method
    }
    response = routeCb(request)
  else
    response = httpServer.notFoundResponse()
  end

  sck:send(response, 
    function()
      --print("Response: " .. response) 
      sck:close() 
    end
  )
end

local function receiverChunks(sck, reqPart)

  local request = reqBuff[sck]

  --print("Chunk: [[\r\n" .. reqPart .. "]]")
  
  -- First chunk
  if request.metaData == nil then

    -- Obtains method, path and queryString
    local _, _, metaData, method, path, queryString = string.find(reqPart, "(([A-Z]+) ([^?]+)%?([^ ]+) HTTP/.-\r?\n)")
    -- In case there's no queryString
    if method == nil then
      _, _, metaData, method, path = string.find(reqPart, "(([A-Z]+) (.+) HTTP/.-\r?\n)")
    end
    request.metaData = metaData
    request.method = method
    request.path = path
    request.queryString = queryString

    local _, _, headers = string.find(reqPart, "\n(.-\r?\n)\r?\n")
    if headers == nil then
      _, _, headers = string.find(reqPart, "\r?\n(.*)")
    end
    request.headers = headers

    -- 'Transfer-Encoding: Chunked' not being treated
    local _, _, length = string.find(reqPart:lower(), "content%-length:%s-(%d+)")
    request.contentLength = tonumber(length)
    if request.contentLength ~= nil and request.contentLength > 0 then
      local _, _, body = string.find(reqPart, "\r?\n\r?\n(.*)$")
      if body ~= nil then
        request.content = body
      end
    end
  else
    request.content = request.content .. reqPart
  end
  if request.contentLength == nil or (request.content and #request.content >= request.contentLength) then
    receiver(sck, request)
    reqBuff[sck] = nil
  end
end

function httpServer.route(route, cb)
  if not string.match(route, "^/") then
    route = "/" .. route
  end
  if string.match(route, "./$") then
    route = string.sub(route, 1, #route - 1)
  end

  local paramNames = {}
  for paramName in string.gmatch(route, '{(.-)}') do
    paramNames[#paramNames+1] = paramName
  end

  httpServer.routeCbs[route] = cb
  httpServer.routeParamNames[route] = paramNames
end

function httpServer.start(startedCb)
  local srv = net.createServer(net.TCP)

  if srv then
    srv:listen(8080, function(conn)
        --print 'Connection received'
        conn:on("receive", receiverChunks)
      end
    )
    port, addr = srv:getaddr()
    print('Server opened: ' .. addr .. ':' .. port)
    startedCb()
  end
end

return httpServer