local Controls = require 'Controls'
local Object = require 'Object'
local tableUtils = require 'tableUtils'

local Player = Object:extended({
  radius = 0.05,
  color = {
    r = 0.5,
    g = 0.5,
    b = 0.5,
  },
  choice = 0,
  playing = false,
  isReady = false,
  score = 0,
  id = 1,
})

function Player:constructor()
  self._initialState = tableUtils.copyInstance(self)
end

function Player:resetState()
  tableUtils.keywiseAnd(self, { _initialState = self._initialState, pos = self.pos })
  tableUtils.merge(self, self._initialState)
  self._initialState = tableUtils.copyInstance(self)
end

function Player:resetChoice()
  if self.playing and not self.isReady then
    self.choice = 0
  end
end

function Player:increase()
  if self.playing and not self.isReady then
    self.choice = self.choice + 1
  end
end

function Player:ready()
  print(self.playing, self.choice)
  if self.playing and self.choice > 0 then
    self.isReady = true
  end
end

-- override
function Player:draw ()
  love.graphics.setColor(self.color.r, self.color.g, self.color.b, 1)
  love.graphics.circle('fill', self.pos.x, self.pos.y, self.radius)
  love.graphics.setLineWidth(0.001)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.circle('line', self.pos.x, self.pos.y, self.radius * 1.05, 100)
  
  local eye1Angle = self.dir + 90
  local eye2Angle = self.dir - 90
  
  local eyesOutterProportion = 0.7
  local eyesSeparationProportion = 0.2
  local eyesSizeProportion = 0.1
  
  local diff = self:getRelativePosAhead(self.radius * eyesOutterProportion)
  local eye1Diff = self:getRelativePosAhead(self.radius * eyesSeparationProportion, eye1Angle)
  local eye2Diff = self:getRelativePosAhead(self.radius * eyesSeparationProportion, eye2Angle)
  
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.circle('fill', self.pos.x + diff.x + eye1Diff.x, self.pos.y + diff.y + eye1Diff.y, self.radius * eyesSizeProportion)
  love.graphics.circle('fill', self.pos.x + diff.x + eye2Diff.x, self.pos.y + diff.y + eye2Diff.y, self.radius * eyesSizeProportion)
end

-- override
Player._controlHandlers = {
  [Controls.RESET] = Player.resetChoice,
  [Controls.READY] = Player.ready,
  [Controls.INCREASE] = Player.increase
}

return Player