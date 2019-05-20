local Object = require 'Object'
local tableUtils = require 'tableUtils'
local debugUtils = require 'debugUtils'

local Collision = Object:extended({
  collisionOn = true
})

Collision._Collisions = setmetatable({}, {__mode = 'v'})

function Collision:constructor(pos)
  Collision:super(self, pos)
  local lst = Collision._Collisions
  lst[#lst+1] = self
end

function Collision:collides(collision)
  error("Collision shape unknown!", 2)
end

function Collision:hasCollision(exclusions)
  exclusions = exclusions or {}
  local revExclusions = tableUtils.reverse(exclusions)
  local collided = false
  for _, collision in ipairs(Collision._Collisions) do
    if collision ~= self and not revExclusions[collision] and collision.collisionOn and self:collides(collision) then
      collided = true
      break
    end
  end
  return collided
end

function Collision:collisions(exclusions)
  exclusions = exclusions or {}
  local revExclusions = tableUtils.reverse(exclusions)
  local allCollisions = {}
  for _, collision in ipairs(Collision._Collisions) do
    if collision ~= self and not revExclusions[collision] and collision.collisionOn and self:collides(collision) then
      allCollisions[#allCollisions+1] = collision
    end
  end
  return allCollisions
end

-- Override
function Collision:_willMove(dt)
  moved = Collision.__proto._willMove(self, dt)
  
  movedObj = tableUtils.copyInstance(self)
  tableUtils.merge(movedObj, moved)
  local collided = false
  if self.collisionOn then
    collided = movedObj:hasCollision({self})
  end
  if collided then
    return {
      pos = tableUtils.copy(self.pos)
    }
  end
  
  return moved
end
return Collision