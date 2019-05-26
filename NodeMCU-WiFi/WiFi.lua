local led1 = 3
local led2 = 6
local sw1 = 1
local sw2 = 2

local led1State = gpio.LOW
gpio.mode(led1, gpio.OUTPUT)
gpio.write(led1, led1State)

gpio.mode(sw1, gpio.INT, gpio.PULLUP)



local reactivateTimer = tmr.create()

local cbchave1

local reactivate = function()
  gpio.trig(sw1, "down", cbchave1)
end

cbchave1 = function()
  gpio.trig(sw1)
  
  m:publish("rafaEGabs", "node",
    0, 0, function (c) print ("enviou!") end)
  
  reactivateTimer:register(200, tmr.ALARM_SINGLE, reactivate)
  reactivateTimer:start()
end

reactivate()

function mqttSubbed()
  m:on("message", 
    function(client, topic, data)
      if topic == 'rafaEGabs' and data == 'lua' then
        if led1State == gpio.LOW then
          led1State = gpio.HIGH
        else
          led1State = gpio.LOW
        end
        gpio.write(led1, led1State)
        print('Led alternado!')
      end
    end
  )
end

function mqttConnected()
  m:subscribe("rafaEGabs",0,
   function (client) 
     print("subscribe success") 
     mqttSubbed()
   end
  )
end

function internetConnected()
  m = mqtt.Client("rafaEGabsNode", 120)
-- conecta com servidor mqtt na porta 1883:
  m:connect("85.119.83.194", 1883, 0,
    -- callback em caso de sucesso  
    function(client)
      print("connected")
      mqttConnected()
    end, 
    -- callback em caso de falha 
    function(client, reason) 
      print("failed reason: "..reason) 
    end
  )
end

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