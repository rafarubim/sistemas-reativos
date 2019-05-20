local Class = require 'Class'
local Fruit = require 'Fruit'


math.randomseed(os.time())

local FruitPanel = Class:extended({
  pos = {
    x = 0,
    y = 0
  },
  currentFruit = nil,
  _currentSprite = nil,
  _bananaSprite = nil,
  _appleSprite = nil,
  _pineappleSprite = nil,
  _grapesSprite = nil,
})

function FruitPanel:LoadBananaImage(imagePath)
  FruitPanel._bananaSprite = love.graphics.newImage(imagePath)
end

function FruitPanel:LoadAppleImage(imagePath)
  FruitPanel._appleSprite = love.graphics.newImage(imagePath)
end

function FruitPanel:LoadPineappleImage(imagePath)
  FruitPanel._pineappleSprite = love.graphics.newImage(imagePath)
end

function FruitPanel:LoadGrapesImage(imagePath)
  FruitPanel._grapesSprite = love.graphics.newImage(imagePath)
end

function FruitPanel:constructor()
  self:randomize()
end

function FruitPanel:randomize()
  self.currentFruit = math.random(1, 4)
end

function FruitPanel:update(dt)
  local sprite = {
    [Fruit.FruitTypes.BANANA] = self._bananaSprite,
    [Fruit.FruitTypes.APPLE] = self._appleSprite,
    [Fruit.FruitTypes.PINEAPPLE] = self._pineappleSprite,
    [Fruit.FruitTypes.GRAPES] = self._grapesSprite
  }
  self._currentSprite = sprite[self.currentFruit]
end

function FruitPanel:draw()
  if self._currentSprite then
    sWidth, sHeight = self._currentSprite:getDimensions()
    love.graphics.draw(self._currentSprite, self.pos.x - sWidth/2, self.pos.y + sHeight/2, 0, 1, -1)
  end
end

return FruitPanel