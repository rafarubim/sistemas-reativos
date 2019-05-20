local Player = require 'Player'
local Controls = require 'Controls'
local Fruit = require 'Fruit'
local Caldron = require 'Caldron'
local RectangleCollision = require 'RectangleCollision'
local Table = require 'Table'
local Score = require 'Score'
local FruitPanel = require 'FruitPanel'
require 'CollisionExtension'
local debugUtils = require 'debugUtils'
local tableUtils = require 'tableUtils'

local windowSizeX = 1000
local windowSizeY = 600
local scale = 1.5
local graphicsWidth = windowSizeX/scale
local graphicsHeight = windowSizeY/scale

local imagesPath = 'images'
local fontsPath = 'fonts'

local score1 = Score:new({
  pos = {
    x = -305,
    y = -50
  }
}, fontsPath .. '/Gameplay.ttf')

local score2 = Score:new({
  pos = {
    x = 30,
    y = -50
  }
}, fontsPath .. '/Gameplay.ttf')

local panel1 = FruitPanel:new({
  pos = {
    x = -95,
    y = -105
  }
})

local panel2 = FruitPanel:new({
  pos = {
    x = 230,
    y = -105
  }
})

local player1 = Player:new({
  pos = {
    x = 140,
    y = 50
  },
  controls = {
    [Controls.UP] = 'w',
    [Controls.DOWN] = 's',
    [Controls.LEFT] = 'a',
    [Controls.RIGHT] = 'd',
    [Controls.ACTION] = 'space'
  },
  score = score1,
  fruitPanel = panel1,
  playerName = 'Jogador azul'
})

local player2 = Player:new({
  pos = {
    x = 140,
    y = 100
  },
  controls = {
    [Controls.UP] = 'up',
    [Controls.DOWN] = 'down',
    [Controls.LEFT] = 'left',
    [Controls.RIGHT] = 'right',
    [Controls.ACTION] = 'rshift'
  },
  score = score2,
  fruitPanel = panel2,
  playerName = 'Jogador vermelho'
})

local banana = Fruit._CurrentFruits[Fruit.FruitTypes.BANANA]
local maca = Fruit._CurrentFruits[Fruit.FruitTypes.APPLE]
local abacaxi = Fruit._CurrentFruits[Fruit.FruitTypes.PINEAPPLE]
local uva = Fruit._CurrentFruits[Fruit.FruitTypes.GRAPES]

local cald = Caldron:new({
  pos = {
    x = 235,
    y = 70
  }
})

local table = Table:new({
  pos = {
    x = -224,
    y = 79
  }
})

local upperWall = RectangleCollision:new({
  pos = {
    x = 0,
    y = graphicsHeight/2
  },
  dim = {
    width = graphicsWidth,
    height = 1
  }
})
local lowerWall = RectangleCollision:new({
  pos = {
    x = 0,
    y = -10
  },
  dim = {
    width = graphicsWidth,
    height = 1
  }
})
local leftWall = RectangleCollision:new({
  pos = {
    x = -graphicsWidth/2,
    y = 0
  },
  dim = {
    width = 1,
    height = graphicsHeight
  }
})
local rightWall = RectangleCollision:new({
  pos = {
    x = graphicsWidth/2,
    y = 0
  },
  dim = {
    width = 1,
    height = graphicsHeight
  }
})

function love.load()
  
  upperWall.pleaseDontCollect = true
  lowerWall.pleaseDontCollect = true
  leftWall.pleaseDontCollect = true
  rightWall.pleaseDontCollect = true
  
  background = love.graphics.newImage(imagesPath .. "/floor.jpg")
  
  banana:loadImage(imagesPath .. "/banana.png")
  maca:loadImage(imagesPath .. "/maca.png")
  abacaxi:loadImage(imagesPath .. "/abacaxi.png")
  uva:loadImage(imagesPath .. "/uva.png")
  
  FruitPanel:LoadBananaImage(imagesPath .. "/banana_maior.png")
  FruitPanel:LoadAppleImage(imagesPath .. "/maca_maior.png")
  FruitPanel:LoadPineappleImage(imagesPath .. "/abacaxi_maior.png")
  FruitPanel:LoadGrapesImage(imagesPath .. "/uva_maior.png")
  
  banana:loadSelectedImage(imagesPath .. "/banana_selecionada.png")
  maca:loadSelectedImage(imagesPath .. "/maca_selecionada.png")
  abacaxi:loadSelectedImage(imagesPath .. "/abacaxi_selecionado.png")
  uva:loadSelectedImage(imagesPath .. "/uva_selecionada.png")
  
  cald:loadImage(imagesPath .. "/panela_cinza.png")
  cald:loadSelectedImage(imagesPath .. "/panela_cinza_selecionada.png")
  
  table:loadImage(imagesPath .. "/table.png" )
  
  borda_azul = love.graphics.newImage(imagesPath .. "/borda_azul.png" )
  borda_vermelha = love.graphics.newImage(imagesPath .. "/borda_vermelha.png" )

  love.window.setTitle('Fruit run')
  love.window.setMode(windowSizeX, windowSizeY)
end

function love.update (dt)
  banana:update(dt)
  maca:update(dt)
  abacaxi:update(dt)
  uva:update(dt)
  cald:update(dt)
  player1:update(dt)
  player2:update(dt)
  panel1:update(dt)
  panel2:update(dt)
end

function love.draw ()
  love.graphics.setColor(1, 1, 1, 1)
  for i = 0, love.graphics.getWidth() / background:getWidth() do
      for j = 0, love.graphics.getHeight() / background:getHeight() do
          love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
      end
  end
  love.graphics.push()
  love.graphics.translate(windowSizeX/2, windowSizeY/2)
  love.graphics.scale(scale, -scale)
  
  --love.graphics.setColor(0,0,0,1)
  --love.graphics.rectangle('fill',upperWall.pos.x-upperWall.dim.width/2,upperWall.pos.y-upperWall.dim.height/2, upperWall.dim.width,upperWall.dim.height)
  --love.graphics.setColor(1,1,1,1)
  
  table:draw()
  
  banana:draw()
  maca:draw()
  abacaxi:draw()
  uva:draw()
  cald:draw()
  
  love.graphics.draw(borda_azul, -480, 10, 0, 1, -1)
  love.graphics.draw(borda_vermelha, 0, -5, 0, 1, -1)
  --love.graphics.draw(abacaxi_maior, 20, -21, 0, 1, -1)
  
  
  panel1:draw()
  panel2:draw()
  
  --love.graphics.draw(maca_maior, 160, -37, 0, 1, -1)
  --love.graphics.draw(uva_maior, -170, -22, 0, 1, -1)
  --love.graphics.draw(banana_maior, -325, -21, 0, 1, -1)
  
  love.graphics.setColor(93/255, 188/255, 210/255)
  player1:draw()
  love.graphics.setColor(255/255, 97/255, 109/255)
  player2:draw()
  
  score1:draw()
  score2:draw()
  
  love.graphics.pop()
end


