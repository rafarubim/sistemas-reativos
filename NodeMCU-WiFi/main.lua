local mqtt = require("mqtt_library")

function mqttcb(topic, message)
    print("Received from topic: " .. topic .. " - message: " .. message)
    if topic == 'rafaEGabs' and message == 'node' then
      controle = not controle
    end
end

function love.keypressed(key)
  if key == 'a' then
    mqtt_client:publish("rafaEGabs", "lua")
  end
end

function love.load()
  controle = false
  mqtt_client = mqtt.client.create("85.119.83.194", 1883, mqttcb)
  mqtt_client:connect("rafaEGabsLua")
  mqtt_client:subscribe({"rafaEGabs"})
end

function love.draw()
   if controle then
     love.graphics.rectangle("line", 10, 10, 200, 150)
   end
end

function love.update(dt)
  mqtt_client:handler()
end
