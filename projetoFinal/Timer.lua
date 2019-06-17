local Class = require 'Class'

local Timer = Class:extended({
  beginning = nil,
  period = nil,
  finishedCb = nil,
})

function Timer:begin(period)
  self.beginning = love.timer.getTime()
  self.period = period
end

function Timer:whenFinished(cb)
  self.finishedCb = cb
end

function Timer:process()
  if self.beginning == nil or self.period == nil then
    return
  end
  local current = love.timer.getTime()
  local delta = current - self.beginning
  
  if delta >= self.period then
    if self.finishedCb then
      self.finishedCb()
    end
    self.beginning = nil
    self.period = nil
    self.finishedCb = nil
    return true
  end
  return false
end

return Timer