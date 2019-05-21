function mqttSubbed()
  m:on("message", 
    function(client, topic, data)   
      print(topic .. ":" )   
      if data ~= nil then print(data) end
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
  m:connect("test.mosquitto.org", 1883, 0,
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