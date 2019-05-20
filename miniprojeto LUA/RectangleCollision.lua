local Collision = require 'Collision'

local RectangleCollision = Collision:extended({
  dim = {
    width = 0,
    height = 0
  }
})

function RectangleCollision:constructor(pos, dim)
  RectangleCollision:super(self, pos)
  self.dim = dim or self.dim
end

return RectangleCollision