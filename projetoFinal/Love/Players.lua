local Class = require 'Class'
local Player = require 'Player'
local Object = require 'Object'
local listUtils = require 'listUtils'
local tableUtils = require 'tableUtils'
local utils = require 'utils'

math.randomseed(os.time())

local Players = Class:extended({
  _nextInsertLeft = true,
  all = {},
  roads = {},
  roadImagePath = nil,
})

function Players:rearrangePlayers()
  local amount = #self.all
  local leftCorner = -1.4
  local rightCorner = 1.95
  local farFromCorner = 1.1 ^ (-amount)
  local dist = rightCorner - leftCorner
  local cutCorner = dist/2 * farFromCorner
  for xVal, inx in utils.spreadValues(leftCorner + cutCorner, rightCorner - cutCorner, amount) do
    self.all[inx].pos.x = xVal
  end
end

function Players:loadRoadImage(imagePath)
  self.roadImagePath = imagePath
end

function Players:getFromId(id)
  return listUtils.first(self.all, function(player) return player.id == id end)
end


function Players:createPlayer(id)
  local exists = self:getFromId(id)
  if not exists then
    local colorLowerLimit = 0.3
    local colorUpperLimit = 0.9
    local colorRange = colorUpperLimit - colorLowerLimit
    local newPlayer = Player:new({
      id = id,
      dir = 90,
      pos = {
        x = 0.15 * (id-1),
        y = 0
      },
      color = {
        r = colorLowerLimit + math.random() * colorRange,
        g = colorLowerLimit + math.random() * colorRange,
        b = colorLowerLimit + math.random() * colorRange
      },
      choice = 1,
    })
    if self._nextInsertLeft then
      table.insert(self.all, 1, newPlayer)
    else
      self.all[#self.all+1] = newPlayer
    end
    self._nextInsertLeft = not self._nextInsertLeft
    self.roads[newPlayer] = Object:new()
    self.roads[newPlayer]:loadImage(self.roadImagePath)
    self:rearrangePlayers()
    return newPlayer
  end
  return nil
end

function Players:update(dt)
  for _, player in ipairs(self.all) do
    self.roads[player].pos = {
      x = player.pos.x,
      y = 0
    }
  end
end

function Players:drawRoads(xScale, yScale, imageXFactor, imageYFactor)
  for _, player in ipairs(self.all) do
    local radiusToRoadProportion = 2.4
    local rectWidth = player.radius * radiusToRoadProportion
    love.graphics.setColor(player.color.r, player.color.g, player.color.b, 1)
    love.graphics.rectangle('fill', player.pos.x - rectWidth/2, -4, rectWidth, 8)
    self.roads[player]:draw(xScale, yScale, imageXFactor, imageYFactor)
  end
end

function Players:drawIds(xScale, yScale, imageXFactor, imageYFactor, font)
  for _, player in ipairs(self.all) do
    local radiusToRectProportion = 2.4
    local rectWidth = player.radius * radiusToRectProportion
    local rectHeight = rectWidth
    local rectY = -0.2
    if player.isReady then
      love.graphics.setColor(player.color.r - 0.3, player.color.g - 0.3, player.color.b - 0.3, 1)
    else
      love.graphics.setColor(player.color.r, player.color.g, player.color.b, 1)
    end
    love.graphics.rectangle('fill', player.pos.x - rectWidth/2, rectY, rectWidth, rectHeight)
    if player.isReady then
      love.graphics.setColor(player.color.r + 0.3, player.color.g + 0.3, player.color.b + 0.3, 1)
    else
      love.graphics.setColor(0, 0, 0)
    end
    love.graphics.setLineWidth(0.01)
    love.graphics.rectangle('line', player.pos.x - rectWidth/2, rectY, rectWidth, rectHeight)
    
    local textAdjustX = 0.03
    local textAdjustY = -0.017
    
    if player.isReady then
      love.graphics.setColor(1, 1, 1)
    else
      love.graphics.setColor(0, 0, 0)
    end
    love.graphics.setFont(font)
    love.graphics.print(utils.numberToLetter(player.id), player.pos.x - rectWidth/2 + textAdjustX, rectY + rectHeight + textAdjustY, 0, 1/xScale, 1/yScale)
  end
end

function Players:drawScores(xScale, yScale, imageXFactor, imageYFactor, font)
  for _, player in ipairs(self.all) do
    if player.playing then
      local textAdjustX = 0.03
      if player.score > 99 then
        textAdjustX = 0
      elseif player.score > 9 then
        textAdjustX = 0.018
      end
      
      love.graphics.setColor(player.color.r - 0.3, player.color.g - 0.3, player.color.b - 0.3)
      love.graphics.circle('fill', player.pos.x, -0.294, player.radius * 1.3)
      
      love.graphics.setColor(player.color.r + 0.3, player.color.g + 0.3, player.color.b + 0.3)
      love.graphics.setFont(font)
      love.graphics.print(tostring(player.score), player.pos.x - player.radius + textAdjustX, -0.267, 0, 1/xScale, 1/yScale)
    end
  end
end

return Players