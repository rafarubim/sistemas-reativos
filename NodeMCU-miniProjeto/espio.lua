local espio = {}

local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

local led1State = gpio.LOW
local led2State = gpio.LOW

gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)

gpio.write(led1, led1State)
gpio.write(led2, led2State)

gpio.mode(sw1, gpio.INT, gpio.PULLUP)
gpio.mode(sw2, gpio.INT, gpio.PULLUP)

local button1Timer = tmr.create()
local button2Timer = tmr.create()

local cbchave1
local cbchave2

local reactivateButton1 = function()
  gpio.trig(sw1, "down", cbchave1)
end

local reactivateButton2 = function()
  gpio.trig(sw2, "down", cbchave2)
end

local button1Cbs = {}

local button2Cbs = {}

function espio.subscribeCbButton1(cb)
  button1Cbs[#button1Cbs+1] = cb
end

function espio.subscribeCbButton2(cb)
  button2Cbs[#button2Cbs+1] = cb
end

local function turnOffGreen()
  gpio.write(led2, gpio.LOW)
end

local function turnOffRed()
  gpio.write(led1, gpio.LOW)
end

function espio.greenBlinkOnce()
  local blinkOnce = tmr.create()
  blinkOnce:register(3000, tmr.ALARM_SINGLE, turnOffGreen)
  blinkOnce:start()
  gpio.write(led2, gpio.HIGH)
end

function espio.redBlinkOnce()
  local blinkOnce = tmr.create()
  blinkOnce:register(3000, tmr.ALARM_SINGLE, turnOffRed)
  blinkOnce:start()
  gpio.write(led1, gpio.HIGH)
end

cbchave1 = function()
  gpio.trig(sw1)
  
  for _, cb in ipairs(button1Cbs) do
    cb()
  end
  
  button1Timer:register(200, tmr.ALARM_SINGLE, reactivateButton1)
  button1Timer:start()
end

reactivateButton1()

cbchave2 = function()
  gpio.trig(sw2)
  
  for _, cb in ipairs(button2Cbs) do
    cb()
  end

  button2Timer:register(200, tmr.ALARM_SINGLE, reactivateButton2)
  button2Timer:start()
end

reactivateButton2()

return espio