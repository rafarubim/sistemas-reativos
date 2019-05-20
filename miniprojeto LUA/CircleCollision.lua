local Collision = require 'Collision'

local CircleCollision = Collision:extended({
  radius = 0
})

function CircleCollision:constructor(pos, radius)
  CircleCollision:super(self, pos)
  self.radius = radius or self.radius
end

return CircleCollision