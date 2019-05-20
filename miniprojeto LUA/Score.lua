local Class = require 'Class'
local Fruit = require 'Fruit'

local Score = Class:extended({
  _font = nil,
  value = 0,
  pos = {
    x = 0,
    y = 0
  }
})

function Score:constructor(fontPath)
  self._font = love.graphics.newFont(fontPath, 72)
end

function Score:draw()
  love.graphics.setColor(0,0,0,1)
  love.graphics.setFont(self._font)
  love.graphics.print(self.value, self.pos.x, self.pos.y, 0 , 1.3, -1.3)
  love.graphics.setColor(1,1,1,1)
end

return Score