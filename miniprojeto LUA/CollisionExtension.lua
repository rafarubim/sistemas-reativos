local RectangleCollision = require 'RectangleCollision'
local CircleCollision = require 'CircleCollision'
local Player = require 'Player'

local function rectanglesCollide(rect1, rect2)
  local xDoesntTouch = math.abs(rect2.pos.x - rect1.pos.x) > rect1.dim.width/2 + rect2.dim.width/2
  local yDoesntTouch = math.abs(rect2.pos.y - rect1.pos.y) > rect1.dim.height/2 + rect2.dim.height/2
  if xDoesntTouch or yDoesntTouch then
    return false
  end
  return true
end

local function circlesCollide(c1, c2)
  local dist = math.sqrt(math.pow(c2.pos.x - c1.pos.x, 2) + math.pow(c2.pos.y - c1.pos.y, 2))
  return dist <= c1.radius + c2.radius
end

local function isInCircle(circ, coord)
  local dist = math.sqrt(math.pow(coord.x - circ.pos.x, 2) + math.pow(coord.y - circ.pos.y, 2))
  return dist <= circ.radius
end

local function rectangleCollideCircle(rect, circ)
  local circAsRect = {
    pos = circ.pos,
    dim = {
      width = circ.radius * 2,
      height = circ.radius * 2
    }
  }
  local rectsColl = rectanglesCollide(rect, circAsRect)
  if not rectsColl then
    return false
  end
  if rect.pos.x == circ.pos.x then
    return rectsColl
  elseif rect.pos.y == circ.pos.y then
    return rectsColl
  end
  local testVertex = {}
  local xDifference = rect.pos.x - circ.pos.x
  if rect.dim.width/2 > math.abs(xDifference) then
    return true
  end
  if xDifference > 0 then
    testVertex.x = rect.pos.x - rect.dim.width/2
  else
    testVertex.x = rect.pos.x + rect.dim.width/2
  end
  local yDifference = rect.pos.y - circ.pos.y
  if rect.dim.height/2 > math.abs(yDifference) then
    return true
  end
  if yDifference > 0 then
    testVertex.y = rect.pos.y - rect.dim.height/2
  else
    testVertex.y = rect.pos.y + rect.dim.height/2
  end
  return isInCircle(circ, testVertex)
end

local function collides(coll1, coll2)
  if coll1:is(RectangleCollision) and coll2:is(RectangleCollision) then
    return rectanglesCollide(coll1, coll2)
  elseif coll1:is(CircleCollision) and coll2:is(CircleCollision) then
    return circlesCollide(coll1, coll2)
  end
  if not coll1:is(RectangleCollision) then
    coll1, coll2 = coll2, coll1
  end
  return rectangleCollideCircle(coll1, coll2)
end

function RectangleCollision:collides(collision)
  return collides(self, collision)
end

function CircleCollision:collides(collision)
  return collides(self, collision)
end