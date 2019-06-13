local tableUtils = require 'tableUtils'
local listUtils = require 'listUtils'
local Controls = require 'Controls'
local CircleCollision = require 'CircleCollision'
local Fruit = require 'Fruit'
local Caldron = require 'Caldron'
local debugUtils = require 'debugUtils'

local Player = CircleCollision:extended({
  _maxSpeed = 300,
  radius = 20,
  score = nil,
  playerNumber = ""
})

-- override
function Player:draw ()
  love.graphics.circle('fill', self.pos.x, self.pos.y, self.radius)
  
  local eye1Angle = self.dir + 90
  local eye2Angle = self.dir - 90
  
  local eyesOutterProportion = 0.7
  local eyesSeparation = 3
  
  local diff = self:getRelativePosAhead(self.radius * eyesOutterProportion)
  local eye1Diff = self:getRelativePosAhead(eyesSeparation, eye1Angle)
  local eye2Diff = self:getRelativePosAhead(eyesSeparation, eye2Angle)
  
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.circle('fill', self.pos.x + diff.x + eye1Diff.x, self.pos.y + diff.y + eye1Diff.y, 2)
  love.graphics.circle('fill', self.pos.x + diff.x + eye2Diff.x, self.pos.y + diff.y + eye2Diff.y, 2)
end

-- override
Player._controlHandlers = {
  [Controls.RESET] = Player.handler,
  [Controls.READY] = Player.handler,
  [Controls.CHOOSE] = Player.handler
}

return Player