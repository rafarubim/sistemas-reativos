local Class = require 'Class'
local Object = require 'Object'
local Enum = require 'Enum'
local StateMachine = require 'StateMachine'
local Timer = require 'Timer'
local utils = require 'utils'

local GameController = Class:extended({
  _stateMachine = nil,
  _choiceButton = nil,
  players = nil,
  timer = nil,
  exponentialChance = 0.5,
  goal = 0,
  choices = {}
})

local States = Enum:create()
States:setValues({'CHOOSING', 'WAITING', 'FINISHED'})
local Events = Enum:create()
Events:setValues({'ALL_READY', 'DELAY_OVER', 'GAME_END', 'RESTART'})

local initialState = States.CHOOSING
local transitions = {
  [States.CHOOSING] = {
    [Events.ALL_READY] = States.WAITING,
    [Events.RESTART] = States.CHOOSING,
  },
  [States.WAITING] = {
    [Events.DELAY_OVER] = States.CHOOSING,
    [Events.GAME_END] = States.FINISHED,
    [Events.RESTART] = States.CHOOSING,
  },
  [States.FINISHED] = {
    [Events.RESTART] = States.CHOOSING,
  },
}

function GameController:constructor()
  self._stateMachine = StateMachine:new({}, initialState, transitions)
  self._stateMachine:onTransition(function(prevState, event, newState)
    print(States:getName(prevState), Events:getName(event), States:getName(newState))
    if event == Events.RESTART then
      self:restart()
    elseif event == Events.DELAY_OVER then
      self:restart()
    end
    if newState == States.CHOOSING then
      self:updateChoices()
    end
  end)
end

local function round(x)
  return math.ceil(x-0.5)
end

local function linearChoices(x)
  return x * 2 - 1
end

local function exponentialChoices(x, nChoices, maxChoice)
  if x == nChoices then
    return 1.4 * maxChoice
  elseif x == nChoices - 1 then
    return 0.9 * maxChoice
  end
  return x
end

function GameController:updateChoices()
  local nPlayers = #self.players.all
  local nChoices = round(nPlayers/2*1.5)
  local maxChoice = nChoices * 2 - 1
  local maxChoiceToGoalProportion = 2.4
  
  self.goal = round(maxChoice * maxChoiceToGoalProportion)
  self.choices = {}
  local doExponential = math.random() < self.exponentialChance
  for i = 1, nChoices do
    if doExponential then
      self.choices[#self.choices+1] = round(exponentialChoices(i, nChoices, maxChoice))
    else
      self.choices[#self.choices+1] = round(linearChoices(i))
    end
  end
end

function GameController:begin(players)
  self.players = players
  self:updateChoices()
end

function GameController:restart()
  for _, player in ipairs(self.players.all) do
    player:resetState()
  end
end

function GameController:update()
  if #self.players.all == 0 then
    return
  end
  if self.timer then
    self.timer:process()
  end
  if self._stateMachine.state == States.CHOOSING then
    local allReady = true
    for _, player in ipairs(self.players.all) do
      if not player.isReady then
        allReady = false
        break
      end
    end
    if allReady then
      self.timer = Timer:new()
      self.timer:whenFinished(function()
        self._stateMachine:send(Events.DELAY_OVER)
        self.timer = nil
      end)
      self.timer:begin(5)
      self._stateMachine:send(Events.ALL_READY)
    end
  end
end

function GameController:loadChoiceButtonImage(imagePath)
  self._choiceButton = Object:new()
  self._choiceButton:loadImage(imagePath)
end

function GameController:drawChoices(xScale, yScale, imageXFactor, imageYFactor, fontChoice, fontMeters)
  local amount = #self.choices
  local leftCorner = -1.75
  local rightCorner = 1.75
  local farFromCorner = 1.1 ^ (-amount)
  local dist = rightCorner - leftCorner
  local cutCorner = dist/2 * farFromCorner
  
  local choiceButtonY = -0.55
  local arrowY = -0.75
  local metersY = -0.88
  self._choiceButton.pos.y = choiceButtonY
  for xVal, inx in utils.spreadValues(leftCorner + cutCorner, rightCorner - cutCorner, amount) do
    self._choiceButton.pos.x = xVal
    self._choiceButton:draw(xScale, yScale, imageXFactor, imageYFactor)
    
    local adjustX = -0.025
    if inx > 9 then
      adjustX = -0.04
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fontChoice)
    love.graphics.print(tostring(inx), xVal + adjustX, choiceButtonY - 0.03, 0, imageXFactor, -imageYFactor)
    
    local arrowWidth = 0.05
    local arrowHeight = 0.035
    love.graphics.setColor(0, 0, 0)
    love.graphics.polygon('fill', xVal - arrowWidth, arrowY, xVal + arrowWidth, arrowY, xVal, arrowY - arrowHeight)
    
    love.graphics.setColor(0.4, 0.1, 0.1)
    love.graphics.circle('fill', xVal, metersY, 0.065)
    
    adjustX = -0.02
    if self.choices[inx] > 99 then
      adjustX = -0.05
    elseif self.choices[inx] > 9 then
      adjustX = -0.034
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fontMeters)
    love.graphics.print(tostring(self.choices[inx]), xVal + adjustX, metersY + 0.03, 0, imageXFactor, -imageYFactor)
  end
end

return GameController