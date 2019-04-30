local currentTime = 0

local function newblip (vel)
  local x, y = 0, 0
  local width, height = love.graphics.getDimensions( )
  local whenActiveAgain = nil
  local function wait (seconds)
    whenActiveAgain = currentTime + seconds
    coroutine.yield()
  end
  local function up()
    while true do
      x = x + 3
      if x > width then
        -- volta para a esquerda da janela
        x = 0
      end
      wait (0.05/vel)
    end
  end
  return {
    update = coroutine.wrap(up),
    affected = function (pos)
      if pos>x and pos<x+10 then
      -- "pegou" o blip
        return true
      else
        return false
      end
    end,
    draw = function ()
      love.graphics.rectangle("line", x, y, 10, 10)
    end,
    getIsActive = function ()
      if whenActiveAgain and currentTime < whenActiveAgain then
        return false
      else
        return true
      end
    end,
  }
end

local function newplayer ()
  local x, y = 0, 200
  local width, height = love.graphics.getDimensions( )
  return {
  try = function ()
    return x
  end,
  update = function (dt)
    x = x + 0.5
    if x > width then
      x = 0
    end
  end,
  draw = function ()
    love.graphics.rectangle("line", x, y, 30, 10)
  end
  }
end

function love.keypressed(key)
  if key == 'a' then
    pos = player.try()
    for i in ipairs(listabls) do
      local hit = listabls[i].affected(pos)
      if hit then
        table.remove(listabls, i) -- esse blip "morre" 
        return -- assumo que apenas um blip morre
      end
    end
  end
end

function love.load()
  player =  newplayer()
  listabls = {}
  for i = 1, 5 do
    listabls[i] = newblip(i)
  end
end

function love.draw()
  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
end

function love.update(dt)
  currentTime = currentTime + dt
  player.update(dt)
  for i = 1,#listabls do
    blip = listabls[i]
    local isActive = blip.getIsActive()
    if isActive then
      blip.update()
    end
  end
end