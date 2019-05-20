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
  pick = {
    range = 10,
    radius = 10
  },
  score = nil,
  fruitPanel = nil,
  selectedFruit = nil,
  carryingFruit = false,
  selectedCaldron = nil,
  playerName = "",
  winScore = 10,
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

function Player:_speedHandler(control, released)
  released = released or false
  local increase = self._maxSpeed
  if released then
    increase = -increase
  end
  local action = {
    [Controls.UP] = function(self, released)
      self.speed.ver = self.speed.ver + increase
    end,
    [Controls.DOWN] = function(self, released)
      self.speed.ver = self.speed.ver - increase
    end,
    [Controls.LEFT] = function(self, released)
      self.speed.hor = self.speed.hor - increase
    end,
    [Controls.RIGHT] = function(self, released)
      self.speed.hor = self.speed.hor + increase
    end
  }
  action[control](self, released)
end

function Player:_actionHandler(_, released)
  if not released then
    if self.selectedFruit and not self.carryingFruit then
      self.carryingFruit = true
      self.selectedFruit.isSelected = false
      self.selectedFruit.isCarried = true
      self.selectedFruit.collisionOn = false
    elseif self.carryingFruit then
      self.carryingFruit = false
      self.selectedFruit.isCarried = false
      self.selectedFruit.collisionOn = true
      local distance = self.radius + self.selectedFruit.radius
      local relativePos = self:getRelativePosAhead(distance)
      self.selectedFruit.pos = {
        x = self.pos.x + relativePos.x,
        y = self.pos.y + relativePos.y
      }
      if self.selectedCaldron then
        local fruitType = self.fruitPanel.currentFruit
        if self.selectedFruit:isType(self.fruitPanel.currentFruit) then
          self.score.value = self.score.value + 1
          self.fruitPanel:randomize()
          if self.score.value >= 10 then
            love.window.showMessageBox('Fim de jogo', self.playerName .. ' ganhou!', 'info', true)
            love.window.close()
            love.event.quit()
          end
        end
        self.selectedFruit:cycleFruit(self.selectedFruit)
      end
      self.selectedFruit = nil
    end
  end
end

function Player:_updateSelect(dt)
  local distance = self.radius + self.pick.range
  local pickCenterDiff = self:getRelativePosAhead(distance)
  local pickColl = CircleCollision:new({
    pos = {
      x = self.pos.x + pickCenterDiff.x,
      y = self.pos.y + pickCenterDiff.y
    },
    radius = self.pick.radius,
    collisionOn = false
  })
  local allCollisions = pickColl:collisions({self})
  
  
    if self.selectedCaldron then
      self.selectedCaldron.isSelected = false
      self.selectedCaldron = nil
    end
  if self.carryingFruit then
    local caldron = listUtils.first(allCollisions, function(elem) return elem:is(Caldron) end)
    if caldron then
      caldron.isSelected = true
      self.selectedCaldron = caldron
    end
  else
    if self.selectedFruit then
      self.selectedFruit.isSelected = false
      self.selectedFruit = nil
    end
    
    local uncarriedFruit = listUtils.first(allCollisions, function(elem) return elem:is(Fruit) and not elem.isCarried end)
    if uncarriedFruit then
      uncarriedFruit.isSelected = true
      self.selectedFruit = uncarriedFruit
    end
  end
end

function Player:_updateCarry(dt)
  if self.carryingFruit then
    local carryOutsideProportion = 0.8
    local distance = self.radius + self.selectedFruit.radius * carryOutsideProportion
    local relativePos = self:getRelativePosAhead(distance)
    self.selectedFruit.pos = {
      x = self.pos.x + relativePos.x,
      y = self.pos.y + relativePos.y
    }
  end
end

-- override
function Player:update(dt)
  Player.__proto.update(self, dt)
  self:_updateSelect(dt)
  self:_updateCarry(dt)
end

-- override
Player._controlHandlers = {
  [Controls.UP] = Player._speedHandler,
  [Controls.DOWN] = Player._speedHandler,
  [Controls.LEFT] = Player._speedHandler,
  [Controls.RIGHT] = Player._speedHandler,
  [Controls.ACTION] = Player._actionHandler
}

return Player