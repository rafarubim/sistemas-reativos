local httpServer = {
  routeCbs = {},
  routeParamNames = {}
}

local function response(body, headers)
  body = body or ''
  headers = headers or {}
  local response = ''
  for k, v in pairs(headers) do
    response = response .. k .. ': ' .. v .. '\n'
  end
  if body ~= '' then
	response = response .. '\n' .. body .. '\n'
  end
  return response
end

function httpServer.okResponse(body, headers)
  return 'HTTP/1.1 200 OK\n' .. response(body, headers)
end

function httpServer.notFoundResponse(body, headers)
  return 'HTTP/1.1 404 NOT FOUND\n' .. response(body, headers)
end

local function receiver(sck, request)
  print("Request: " .. request)

  -- Obtains method, path and queryString
  local _, _, method, path, queryString = string.find(request, "([A-Z]+) ([^?]+)%?([^ ]+) HTTP")
  -- In case there's no queryString
  if method == nil then
    _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
  end

  local _, _, body = string.find(request, "HTTP/1.1.*\n\n(.*)")
  
  if not method or not path then
	print('Request error')
	sck:close() 
	return
  end

  local queryParams = {}
  if queryString ~= nil then
    for k, v in string.gmatch(queryString, "(%w+)=([^&]+)") do
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
    local matches = { string.match(path, templateRegex) }
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
      body = body,
      pathParams = pathParams,
      queryParams = queryParams,
      method = method
    }
    response = routeCb(request)
  else
    response = httpServer.notFoundResponse()
  end
  
  sck:send(response, 
    function()
      print("Response: " .. response) 
      sck:close() 
    end
  )
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

function httpServer.start()
  local srv = net.createServer(net.TCP)

  if srv then
    srv:listen(8080, function(conn)
        print 'Connection received'
        conn:on("receive", receiver)
      end
    )
    port, addr = srv:getaddr()
    print('Server opened: ' .. addr .. ':' .. port)
  end
end

return httpServer