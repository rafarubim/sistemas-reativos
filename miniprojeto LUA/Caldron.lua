local RectangleCollision = require 'RectangleCollision'

local Caldron = RectangleCollision:extended({
  dim = {
    width = 35,
    height = 35
  },
  _caldronSprite = nil,
  _selectedSprite = nil,
  isSelected = false
})

-- override
function Caldron:loadImage(imagePath)
  Caldron.__proto.loadImage(self, imagePath)
  self._caldronSprite = self._currentSprite
end

function Caldron:loadSelectedImage(imagePath)
  Caldron.__proto.loadImage(self, imagePath)
  self._selectedSprite = self._currentSprite
  self._currentSprite = self._caldronSprite
end

-- override
function Caldron:update(dt)
  Caldron.__proto.update(self, dt)
  if self.isSelected then
    self._currentSprite = self._selectedSprite
  else
    self._currentSprite = self._caldronSprite
  end
end

return Caldron