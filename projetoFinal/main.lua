local mqtt = require("mqtt_library")
local id = 0

function mqttcb(topic, message)
    print("Received from topic: " .. topic .. " - message: " .. message)
    if topic == 'rafaEGabsGetId' and message == 'id' then
      mqtt_client:publish("rafaEGabsGetId", tostring(id))
      id = id + 1
    end
end

function love.load()
  controle = false
  mqtt_client = mqtt.client.create("iot.eclipse.org", 1883, mqttcb)
  mqtt_client:connect("rafaEGabsLua")
  mqtt_client:subscribe({"rafaEGabsGetId"})
  mqtt_client:subscribe({"rafaEGabsTestId"})
end

function love.update(dt)
  mqtt_client:handler()
end
