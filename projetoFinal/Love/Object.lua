local Class = require 'Class'
local Controls = require 'Controls'
local tableUtils = require 'tableUtils'
local Timer = require 'Timer'

local Object = Class:extended({
  pos = {
    x = 0,
    y = 0
  },
  speed = {
    hor = 0,
    ver = 0
  },
  dir = 0,
  _currentSprite = nil,
  _gotoTimer = nil,
})

function Object:constructor(pos)
  Object:super(self)
  self.pos = pos or self.pos
end

function Object:loadImage(imagePath)
  self._currentSprite = love.graphics.newImage(imagePath)
end

function Object:getRelativePosAhead(distance, angle)
  angle = angle or self.dir
  local radianAngle = angle * math.pi / 180
  return {
    x = math.cos(radianAngle) * distance,
    y = math.sin(radianAngle) * distance
  }
end

function Object:gotoPos(x, y, time, cb)
  cb = cb or nil
  local deltaX = x - self.pos.x
  local deltaY = y - self.pos.y
  self.speed.hor = deltaX / time
  self.speed.ver = deltaY / time
  self._gotoTimer = Timer:new()
  self._gotoTimer:whenFinished(function()
    self.speed.hor = 0
    self.speed.ver = 0
    if cb then
      cb()
    end
    self._gotoTimer = nil
  end)
  self._gotoTimer:begin(time)
end

function Object:_willMove(dt)
  local moved = {
    pos = tableUtils.copy(self.pos)
  }
  moved.pos.x = moved.pos.x + self.speed.hor * dt
  moved.pos.y = moved.pos.y + self.speed.ver * dt
  return moved
end

function Object:_willUpdate(dt)
  local moved = self:_willMove(dt)
  local updated = {}
  tableUtils.merge(updated, moved)
  return updated
end

function Object:controlEvent(control)
  local handler = self._controlHandlers[Controls[control]]
  if handler then
    handler(self, control)
  end
end

function Object:_updateDir(dt)
  local arc = self.dir
  if self.speed.ver ~= 0 or self.speed.hor ~= 0 then
    arc = math.atan2(self.speed.ver, self.speed.hor)
    arc = arc / math.pi * 180
    if arc < 0 then
      arc = arc + 360
    end
  end
  if self.dir then
    self.dir = arc
  end
end

function Object:update(dt)
  local updated = self:_willUpdate(dt)
  tableUtils.merge(self, updated)
  
  self:_updateDir(dt)
  if self._gotoTimer then
    self._gotoTimer:process()
  end
end

function Object:draw(xScale, yScale, imageXFactor, imageYFactor)
  xScale = xScale or 1
  yScale = yScale or 1
  if self._currentSprite then
    sWidth, sHeight = self._currentSprite:getDimensions()
    local objWidth = sWidth * imageXFactor^2 * xScale
    local objHeight = sHeight * imageYFactor^2 * yScale
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self._currentSprite, self.pos.x - objWidth/2, self.pos.y - objHeight/2, 0, xScale * imageXFactor^2, yScale * imageXFactor^2)
  else
    error("I don't know how to draw this object!", 2)
  end
end

Object._controlHandlers = {}

return Object