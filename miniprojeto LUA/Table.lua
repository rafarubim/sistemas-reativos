local RectangleCollision = require 'RectangleCollision'

local Table = RectangleCollision:extended({
  dim = {
    width = 31,
    height = 152
  }
})

function Table:draw()
  Table.__proto.draw(self)
  --love.graphics.setColor(0,0,0,1)
  --love.graphics.rectangle('fill',self.pos.x-self.dim.width/2,self.pos.y-self.dim.height/2, self.dim.width,self.dim.height)
  --love.graphics.setColor(1,1,1,1)
end

return Table