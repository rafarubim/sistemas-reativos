--NODE-MCU----

local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2


gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)

gpio.mode(sw1, gpio.INT, gpio.PULLUP)
gpio.mode(sw2, gpio.INT, gpio.PULLUP)

gpio.write(led2, gpio.LOW)
gpio.write(led1, gpio.LOW)


local button1State = false
local button2State = false

local hasPressedBothButtons = false

local button1Timer = tmr.create()
local button2Timer = tmr.create()

local cbButton1Up
local cbButton2Up

local cbButton1Down
local cbButton2Down

local idPlayer 

local currentTopic = "rafaEGabsGetId"


local function turnOffGreen()
  gpio.write(led2, gpio.LOW)
end

local function turnOffRed()
  gpio.write(led1, gpio.LOW)
end

local function turnOffRedAndGreen()
  gpio.write(led1, gpio.LOW)
  gpio.write(led2, gpio.LOW)
end

function greenBlinkOnce()
  local blinkOnce = tmr.create()
  blinkOnce:register(300, tmr.ALARM_SINGLE, turnOffGreen)
  blinkOnce:start()
  gpio.write(led2, gpio.HIGH)
end

function redBlinkOnce()
  local blinkOnce = tmr.create()
  blinkOnce:register(300, tmr.ALARM_SINGLE, turnOffRed)
  blinkOnce:start()
  gpio.write(led1, gpio.HIGH)
end


function redAndGreenBlinkOnce()
  local blinkOnce = tmr.create()
  blinkOnce:register(300, tmr.ALARM_SINGLE, turnOffRedAndGreen)
  blinkOnce:start()
  gpio.write(led1, gpio.HIGH)
  gpio.write(led2, gpio.HIGH)
end

local reactivateButton1TriggerUp = function()
  gpio.trig(sw1, "up", cbButton1Up)
end

local reactivateButton2TriggerUp = function()
   gpio.trig(sw2, "up", cbButton2Up)
end



local reactivateButton1TriggerDown = function()
  gpio.trig(sw1, "down", cbButton1Down)
end

local reactivateButton2TriggerDown = function()
  gpio.trig(sw2, "down", cbButton2Down)
end


cbButton1Up = function()
  gpio.trig(sw1)
  button1Timer:register(100, tmr.ALARM_SINGLE, reactivateButton1TriggerDown)
  button1Timer:start()
  if(button2State == true) then
    mqttPublish(currentTopic, tostring(idPlayer) .. " READY")
    hasPressedBothButtons = true
    --print("ENVIOU READY")  
    redAndGreenBlinkOnce()
  else
    if(hasPressedBothButtons == true) then
      hasPressedBothButtons = false
    else
      mqttPublish(currentTopic, tostring(idPlayer) .. " RESET")
      --print("ENVIOU RESET") 
      redBlinkOnce()
    end
  end
button1State = false
end

cbButton2Up = function()
  gpio.trig(sw2)
  button2Timer:register(100, tmr.ALARM_SINGLE, reactivateButton2TriggerDown)
  button2Timer:start()
  if(button1State == true) then
    mqttPublish(currentTopic, tostring(idPlayer) .. " READY")
    hasPressedBothButtons = true
    --print("ENVIOU READY")
    redAndGreenBlinkOnce()
  else
    if(hasPressedBothButtons == true) then
      hasPressedBothButtons = false
    else
      mqttPublish(currentTopic, tostring(idPlayer) .. " INCREASE")
      --print("ENVIOU INCREASE") 
      greenBlinkOnce()
    end
  end  
button2State = false
end




cbButton1Down = function()
  gpio.trig(sw1)
  button1Timer:register(100, tmr.ALARM_SINGLE, reactivateButton1TriggerUp)
  button1Timer:start()
  button1State = true
end



cbButton2Down = function()
  gpio.trig(sw2)
  button2Timer:register(100, tmr.ALARM_SINGLE, reactivateButton2TriggerUp)
  button2Timer:start()
  button2State = true
end


gpio.trig(sw1, "down", cbButton1Down)

gpio.trig(sw2, "down", cbButton2Down)

----------SERVIDOR---------------------------


function internetConnected()
  m = mqtt.Client("rafaEGabsPlayer", 120)
-- conecta com servidor mqtt na porta 1883:
  m:connect("broker.hivemq.com", 1883
    , 0,
    -- callback em caso de sucesso  
    function(client)
      print("Connecting controller, please wait...")
      mqttSubscribe(currentTopic)
    end, 
    -- callback em caso de falha 
    function(client, reason) 
      print("failed reason: "..reason) 
    end
  )
end


function mqttSubscribe(topic)
  m:subscribe(topic,0,
  function (client) 
    --print("subscribe success")
    if(topic == "rafaEGabsGetId") then
      mqttSubbedGetId()
      mqttPublish(topic,"id")
    elseif (topic == "rafaEGabsControl") then
      print("Controller Connected!")
    end
   end
  )
end

function mqttPublish(topic,message)
  m:publish(topic, message,
           0, 0)
end

function mqttSubbedGetId()
  m:on("message", 
    function(client, topic, data)    
      if data ~= nil and topic == "rafaEGabsGetId" and data ~= "id" then 
        idPlayer=data
        mqttUnsubscribeGetId(currentTopic)
        currentTopic = "rafaEGabsControl"
        mqttSubscribe(currentTopic)
      end
    end
  )
end

function mqttUnsubscribeGetId(topic)
  m:unsubscribe(topic)
end


-----------------WI-FI-----------------------------

wificonf = {  
  -- verificar ssid e senha  
  ssid = "Rafa",  
  pwd = "rafagato",  
  got_ip_cb = function (con)
    print ("meu IP: ", con.IP)
    internetConnected()
  end,
  save = false
}

wifi.setmode(wifi.STATION)
wifi.sta.config(wificonf)



