local Class = require 'Class'
local Object = require 'Object'
local Enum = require 'Enum'
local StateMachine = require 'StateMachine'
local Timer = require 'Timer'
local utils = require 'utils'
local tableUtils = require 'tableUtils'

local GameController = Class:extended({
  _stateMachine = nil,
  _choiceButton = nil,
  players = nil,
  playersInRound = {},
  timer = nil,
  exponentialChance = 0.9,
  goal = 0,
  choices = {},
  animationTime = 5
})

local States = Enum:create()
States:setValues({'LOBBY', 'CHOOSING', 'WAITING', 'REARRANGING', 'FINISHED'})
local Events = Enum:create()
Events:setValues({'ALL_READY', 'DELAY_OVER', 'NEW_PLAYER', 'GAME_END', 'RESTART'})

local initialState = States.LOBBY
local transitions = {
  [States.LOBBY] = {
    [Events.ALL_READY] = States.CHOOSING,
  },
  [States.CHOOSING] = {
    [Events.ALL_READY] = States.WAITING,
    [Events.RESTART] = States.LOBBY,
  },
  [States.REARRANGING] = {
    [Events.DELAY_OVER] = States.CHOOSING,
    [Events.RESTART] = States.LOBBY,
  },
  [States.WAITING] = {
    [Events.DELAY_OVER] = States.CHOOSING,
    [Events.NEW_PLAYER] = States.REARRANGING,
    [Events.GAME_END] = States.FINISHED,
    [Events.RESTART] = States.LOBBY,
  },
  [States.FINISHED] = {
    [Events.RESTART] = States.LOBBY,
  },
}

function GameController:startTimer(time, cb)
  self.timer = Timer:new()
  self.timer:whenFinished(function()
    self.timer = nil
    cb()
  end)
  self.timer:begin(time)
end

function GameController:freePlayers()
  for _, player in ipairs(self.players.all) do
    player.isReady = false
    player.choice = 0
  end
end

function GameController:constructor()
  self._stateMachine = StateMachine:new({}, initialState, transitions)
  self._stateMachine:onTransition(function(prevState, event, newState)
    print(States:getName(prevState), Events:getName(event), States:getName(newState))
    if event == Events.RESTART then
      self:restart()
    end
    if prevState == States.LOBBY then
      self:newPlayersEnterRound()
      self:freePlayers()
      self:updateChoices()
    end
    if prevState == States.WAITING then
      self:freePlayers()
      self:updateChoices()
    end
    if newState == States.REARRANGING then
      self:newPlayersEnterRound()
      self:rearrangePlayers()
      self:startTimer(self.animationTime, function()
        self._stateMachine:send(Events.DELAY_OVER)
      end)
    elseif newState == States.WAITING then
      self:processResults()
    end
  end)
end

function GameController:getScoreMetersY(score)
  local initialY = 0
  local penultimateY = 0.76
  local finalY = 0.935
  if (score >= self.goal) then
    return finalY
  end
  return initialY+(penultimateY-initialY) * (score/(self.goal - 1))
end

function GameController:processResults()
  local maxChoices = #self.choices
  local chosen = setmetatable({}, {__index=function() return 0 end})
  for _, player in ipairs(self.playersInRound) do
    local choice = player.choice
    if choice > maxChoices then
      choice = maxChoices
    end
    chosen[choice] = chosen[choice] + 1
  end
  local initialY = 0
  local penultimateY = 0.76
  local finalY = 0.935
  for _, player in ipairs(self.playersInRound) do
    if chosen[player.choice] == 1 then
      player.score = player.score + self.choices[player.choice]
      player:gotoPos(player.pos.x, self:getScoreMetersY(player.score), self.animationTime)
    end
  end
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

function GameController:newPlayersEnterRound()
  if #self.players.all > #self.playersInRound then
    self.playersInRound = tableUtils.copy(self.players.all, self.players.all)
  end
  for _, player in ipairs(self.playersInRound) do
    player.playing = true
  end
end

function GameController:rearrangePlayers()
  local nPlayers = #self.playersInRound
  local nChoices = round(nPlayers/2*1.5)
  local maxChoice = nChoices * 2 - 1
  local maxChoiceToGoalProportion = 2.4
  self.goal = round(maxChoice * maxChoiceToGoalProportion)
  for _, player in ipairs(self.playersInRound) do
    player:gotoPos(player.pos.x, self:getScoreMetersY(player.score), self.animationTime, function() player.dir = 90 end)
  end
end

function GameController:updateChoices()
  if not self.players or #self.playersInRound < 3 then
    return
  end
  local nPlayers = #self.playersInRound
  local nChoices = round(nPlayers/2*1.5)
  local maxChoice = nChoices * 2 - 1
  
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
end

function GameController:restart()
  for _, player in ipairs(self.players.all) do
    player:resetState()
  end
end

function GameController:update()
  if self.timer then
    self.timer:process()
  end
  local state = self._stateMachine.state
  if state ~= States.LOBBY then
    for _, player in ipairs(self.players.all) do
      if not player.playing then
        player.isReady = true
      end
    end
  end
  if state == States.LOBBY then
    local allReady = true
    for _, player in ipairs(self.players.all) do
      player.playing = true
      if not player.isReady then
        allReady = false
        break
      end
    end
    if #self.players.all >= 3 and allReady then
      self._stateMachine:send(Events.ALL_READY)
    end
  elseif state == States.CHOOSING then
    local allReady = true
    for _, player in ipairs(self.playersInRound) do
      if not player.isReady then
        allReady = false
        break
      end
    end
    if allReady then
      self:startTimer(self.animationTime, function()
        if #self.players.all > #self.playersInRound then
          self._stateMachine:send(Events.NEW_PLAYER)
        else
          self._stateMachine:send(Events.DELAY_OVER)
        end
      end)
      self._stateMachine:send(Events.ALL_READY)
    end
  end
end

function GameController:loadChoiceButtonImage(imagePath)
  self._choiceButton = Object:new()
  self._choiceButton:loadImage(imagePath)
end

function GameController:drawChoices(xScale, yScale, imageXFactor, imageYFactor, fontChoice, fontMeters)
  local state = self._stateMachine.state
  if state ~= States.CHOOSING and state ~= States.REARRANGING then
    return
  end
  
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

function GameController:drawCurrentState(xScale, yScale, imageXFactor, imageYFactor, fontState)
  local message1 = ''
  local message2 = ''
  local message3 = ''
  local message4 = ''
  local message5 = ''
  local state = self._stateMachine.state
  if state == States.LOBBY then
    message1 = 'To begin, at least'
    message2 = 'all players must'
    message3 = 'be ready (at'
    message4 = 'least 3)'
  elseif state == States.CHOOSING then
    message1 = 'Hey everyone!'
    message2 = 'Choose how'
    message3 = 'much you want'
    message4 = 'to advance!'
  elseif state == States.WAITING then
    message1 = 'End of round!'
  elseif state == States.REARRANGING then
    message1 = 'New player'
    message2 = 'entered since the'
    message3 = 'previous round.'
    message4 = 'Rearranging'
    message5 = 'players.'
  end
  love.graphics.setColor(0, 0, 0)
  love.graphics.setFont(fontState)
  love.graphics.print(message1, -1.48, 0.7, 0, imageXFactor, -imageYFactor)
  love.graphics.print(message2, -1.48, 0.6, 0, imageXFactor, -imageYFactor)
  love.graphics.print(message3, -1.48, 0.5, 0, imageXFactor, -imageYFactor)
  love.graphics.print(message4, -1.48, 0.4, 0, imageXFactor, -imageYFactor)
  love.graphics.print(message5, -1.48, 0.3, 0, imageXFactor, -imageYFactor)
end

function GameController:drawGoal(xScale, yScale, imageXFactor, imageYFactor, fontGoal)
  love.graphics.setColor(0.4, 0.1, 0.1)
  love.graphics.setFont(fontGoal)
  love.graphics.print('Goal: ' .. self.goal .. 'm', -1.48, 0.9, 0, imageXFactor, -imageYFactor)
end

return GameController