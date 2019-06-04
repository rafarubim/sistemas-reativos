package.loaded.wiFi = nil
local wiFi = require 'wiFi'
package.loaded.httpServer = nil
local httpServer = require 'httpServer'

local led1 = 3
local led2 = 6
local leds = {led1, led2}

for _,ledi in ipairs (leds) do
  gpio.mode(ledi, gpio.OUTPUT)
end

for _,ledi in ipairs (leds) do
  gpio.write(ledi, gpio.LOW)
end

local function answerPage(req)
  req.body = req.body or ''
  print("Body received: " .. req.body)
  gpio.write(led1, gpio.HIGH);

  return httpServer.okResponse()
end

httpServer.route('/answer', answerPage)

wiFi.connect('Rafa', 'rafagato', httpServer.start)