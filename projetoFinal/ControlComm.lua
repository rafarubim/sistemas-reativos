local Class = require 'Class'
local mqtt = require("mqtt_library")

local ControlComm = Class:extended({
  __mqttCb = nil,
  __controlConnected = function() end,
  __controlEvent = function() end,
  __mqttClient = nil,
  clientName = 'rafaEGabsLua',
  idDistributorTopic = 'rafaEGabsGetId',
  idReqMsg = 'id',
  controlTopic = 'rafaEGabsControl',
  controlId = 1,
})

function ControlComm:begin(controlConnectedCb, controlEventCb)
  function self.__mqttCb(topic, message)
    print("Received from topic: " .. topic .. " - message: " .. message)
    if topic == self.idDistributorTopic and message == self.idReqMsg then
      self.__mqttClient:publish(self.idDistributorTopic, tostring(self.controlId))
      self.__controlConnected(self.controlId)
      self.controlId = self.controlId + 1
    elseif topic == self.controlTopic then
      local _, _, id, control = string.find(message, '^(%d+) (%w+)$')
      if (id ~= nil) then
        id = tonumber(id)
        self.__controlEvent(id, control)
      end
    end
  end
  self.__mqttClient = mqtt.client.create("broker.hivemq.com", 1883, self.__mqttCb)
  self.__mqttClient:connect(self.clientName)
  self.__mqttClient:subscribe({ self.idDistributorTopic })
  self.__mqttClient:subscribe({ self.controlTopic })
  
  if type(controlConnectedCb) == 'function' then
    self.__controlConnected = controlConnectedCb
  end
  if type(controlEventCb) == 'function' then
    self.__controlEvent = controlEventCb
  end
end

function ControlComm:handler()
  self.__mqttClient:handler()
end

function ControlComm:mockConnect()
  self.__mqttClient:publish(self.idDistributorTopic, 'id')
end

function ControlComm:mockControl(str)
  self.__mqttClient:publish(self.controlTopic, str)
end

return ControlComm
