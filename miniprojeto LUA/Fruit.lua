local listUtils = require 'listUtils'
local tableUtils = require 'tableUtils'
local debugUtils = require 'debugUtils'
local Enum = require 'Enum'
local CircleCollision = require 'CircleCollision'

local Fruit = CircleCollision:extended({
  radius = 10,
  isSelected = false,
  isCarried = false,
  _fruitSprite = nil,
  _selectedSprite = nil
})

-- override
function Fruit:loadImage(imagePath)
  Fruit.__proto.loadImage(self, imagePath)
  self._fruitSprite = self._currentSprite
end

function Fruit:loadSelectedImage(imagePath)
  Fruit.__proto.loadImage(self, imagePath)
  self._selectedSprite = self._currentSprite
  self._currentSprite = self._fruitSprite
end

-- override
function Fruit:update(dt)
  Fruit.__proto.update(self, dt)
  if self.isSelected then
    self._currentSprite = self._selectedSprite
  else
    self._currentSprite = self._fruitSprite
  end
end

local defaultPositions = {
  {
    x = -226,
    y = 109
  },
  {
    x = -224,
    y = 144
  },
  {
    x = -226,
    y = 69
  },
  {
    x = -226,
    y = 29
  }
}

Fruit.FruitTypes = Enum:create()

Fruit.FruitTypes:setValues({'BANANA', 'APPLE', 'PINEAPPLE', 'GRAPES'})

Fruit._CurrentFruits = {
  Fruit:new({pos = tableUtils.copy(defaultPositions[Fruit.FruitTypes.BANANA])}),
  Fruit:new({pos = tableUtils.copy(defaultPositions[Fruit.FruitTypes.APPLE])}),
  Fruit:new({pos = tableUtils.copy(defaultPositions[Fruit.FruitTypes.PINEAPPLE])}),
  Fruit:new({pos = tableUtils.copy(defaultPositions[Fruit.FruitTypes.GRAPES])})
}

function Fruit:cycleFruit()
  local _, inx = listUtils.first(Fruit._CurrentFruits, self)
  Fruit._CurrentFruits[inx].pos = tableUtils.copy(defaultPositions[inx])
end

function Fruit:isType(fruitType)
  local _, inx = listUtils.first(Fruit._CurrentFruits, self)
  return fruitType == inx
end

return Fruit