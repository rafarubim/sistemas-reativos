local Players = require 'Players'
local Player = require 'Player'
local ControlComm = require 'ControlComm'
local GameController = require 'GameController'
local Object = require 'Object'

local imagesPath = 'images'
local fontsPath = 'fonts'

local fullscreen = false

local graphic = {
  xLimit = 1.5,
  yLimit = 1,
  xScale = 1,
  yScale = 1,
  imageXFactor = 1/320,
  imageYFactor = 1/320,
}

local heightProportion = graphic.yLimit/graphic.xLimit

local virtualWindow = {
  width = 0,
  height = 0,
  xTranslation = 0,
  yTranslation = 0
}

local windowWidth = 960

local window = {
  width = windowWidth,
  height = windowWidth * heightProportion,
}

local function updateWindow(width, height)
  window.width, window.height = width, height
  local expectedHeight = window.width * heightProportion
  if expectedHeight <= window.height then
    virtualWindow.width = window.width
    virtualWindow.height = expectedHeight
  else
    virtualWindow.width = window.height / heightProportion
    virtualWindow.height = window.height
  end
  graphic.xScale = virtualWindow.width/graphic.xLimit/2
  graphic.yScale = -virtualWindow.height/graphic.yLimit/2
  virtualWindow.xTranslation = (window.width - virtualWindow.width)/2/graphic.xScale
  virtualWindow.yTranslation = (virtualWindow.height - window.height)/2/graphic.yScale
end

local controlComm = ControlComm:new()
local players = Players:new()
local gameController = GameController:new()
local gameplayFont = love.graphics.newFont(fontsPath .. '/gameplay.ttf', 24)
local arcadeFont = love.graphics.newFont(fontsPath .. '/arcade.ttf', 24)
local arcadeFont48 = love.graphics.newFont(fontsPath .. '/arcade.ttf', 48)
local defaultFont = love.graphics.newFont(18)

local menuY = -0.06
local sideMenuX = -0.97

local bckg = Object:new()
local menuPanel = Object:new({
  pos = {
    x = 0,
    y = (menuY-graphic.yLimit)/2
  }
})
local sideMenuPanel = Object:new({
  pos = {
    x = (sideMenuX-graphic.xLimit)/2,
    y = (graphic.yLimit+menuY)/2
  }
})
local flag = Object:new({
  pos = {
    x = 0,
    y = 0.85,
  }
})

function love.resize(width, height)
  updateWindow(width, height)
end

local mockId = 1

function love.keypressed(key)
  --if key == 'f' then
  --  fullscreen = not fullscreen
  --  love.window.setFullscreen(fullscreen)
  if key == '1' or key == '2' or key == '3' or key == '4' or key == '5' or key == '6' or key == '7' or key == '8' or key == '9' then
    mockId = tonumber(key)
  elseif key == 'n' then
    controlComm:mockConnect()
  elseif key == 'i' then
    controlComm:mockControl(mockId .. ' INCREASE')
  elseif key == 't' then
    controlComm:mockControl(mockId .. ' RESET')
  elseif key == 'r' then
    controlComm:mockControl(mockId .. ' READY')
  elseif key == 'l' then
    gameController.choices[#gameController.choices+1] = 123
  elseif key == 'p' then
    players.all = {}
  elseif key == 'x' then
    graphic.xScale = 1
    graphic.yScale = 1
  end
end

function love.load()
  love.window.setMode( window.width, window.height, { fullscreen = fullscreen } )
  updateWindow(window.width, window.height)
  
  controlComm:begin(
    function(id)
      players:createPlayer(id)
    end,
    function(id, command)
      local player = players:getFromId(id)
      if player ~= nil then
        player:controlEvent(command)
      end
    end
  )
  
  gameController:begin(players)
  
  bckg:loadImage(imagesPath .. '/bckg2.png')
  menuPanel:loadImage(imagesPath .. '/greaterPanel.png')
  sideMenuPanel:loadImage(imagesPath .. '/greaterPanel.png')
  flag:loadImage(imagesPath .. '/flag2.png')
  players:loadRoadImage(imagesPath .. '/road4.png')
  gameController:loadChoiceButtonImage(imagesPath .. '/choiceButton.png')
  gameController:loadChosenButtonImage(imagesPath .. '/chosenButton.png')
  gameController:loadPointingHandImage(imagesPath .. '/pointingHand.png')
  
  --players:createPlayer(1)
  --players:createPlayer(2)
  --players:createPlayer(3)
  --players:createPlayer(4)
  --players:createPlayer(5)
  --players:createPlayer(6)
  --players:createPlayer(7)
end

function love.mousepressed(x, y, button)
  x = x / graphic.xScale - virtualWindow.xTranslation - graphic.xLimit
  y = y / graphic.yScale - virtualWindow.yTranslation + graphic.yLimit
  if button == 1 then
    gameController:mousePressed(x, y)
  end
end

function love.update(dt)
  controlComm:handler(dt)
  for _, player in ipairs(players.all) do
    player:update(dt)
  end
  players:update(dt)
  gameController:update(dt)
end

function love.draw()
  love.graphics.clear(1,1,1)
  
  love.graphics.push()
  
  love.graphics.scale(graphic.xScale, graphic.yScale)
  love.graphics.translate(virtualWindow.xTranslation, virtualWindow.yTranslation)
  love.graphics.translate(graphic.xLimit, -graphic.yLimit)
  
  bckg:draw(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor)
  
  players:drawRoads(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor)
  
  flag:draw(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor)
  
  for _, player in ipairs(players.all) do
    player:draw(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor)
  end
  
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle('fill', -graphic.xLimit, -graphic.yLimit, graphic.xLimit * 2, graphic.yLimit + menuY)
  
  menuPanel:draw(graphic.xScale * 2.41, graphic.yScale / 1.32, graphic.imageXFactor, graphic.imageYFactor)
  sideMenuPanel:draw(graphic.xScale / 2.35, graphic.yScale / 1.18, graphic.imageXFactor, graphic.imageYFactor)
  
  love.graphics.setColor(0,0,0)
  love.graphics.setFont(defaultFont)
  love.graphics.print('Player Number:', -graphic.xLimit + 0.05 , -0.097, 0, 1/graphic.xScale, 1/graphic.yScale)
  
  love.graphics.setColor(0,0,0)
  love.graphics.setFont(defaultFont)
  love.graphics.print('Current meters:', -graphic.xLimit + 0.05 , -0.247, 0, 1/graphic.xScale, 1/graphic.yScale)
  
  players:drawIds(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor, gameplayFont)
  
  players:drawScores(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor, arcadeFont)
  
  gameController:drawChoices(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor, gameplayFont, arcadeFont)
  gameController:drawCurrentState(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor, defaultFont)
  gameController:drawGoal(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor, defaultFont)
  gameController:drawRestartButton(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor, arcadeFont48)
  gameController:drawResults(graphic.xScale, graphic.yScale, graphic.imageXFactor, graphic.imageYFactor, gameplayFont, arcadeFont)
  
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle('fill', -graphic.xLimit, -graphic.yLimit, -graphic.xLimit * 2, graphic.yLimit * 2)
  love.graphics.rectangle('fill', graphic.xLimit, -graphic.yLimit, graphic.xLimit * 2, graphic.yLimit * 2)
  
  love.graphics.pop()
end
