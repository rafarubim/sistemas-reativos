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
  exponentialChance = 0.1,
  goal = 0,
  choices = {},
  chosen = {},
  animationTime = 5,
  champion = nil,
  chosenButton = nil,
  darkChosenButton = nil,
  pointingHand = nil,
})

local States = Enum:create()
States:setValues({'LOBBY', 'CHOOSING', 'WAITING', 'REARRANGING', 'FINISHED'})
local Events = Enum:create()
Events:setValues({'ALL_READY', 'DELAY_OVER', 'NEW_PLAYER', 'GAME_END', 'RESTART'})

local initialState = States.LOBBY
local transitions = {
  [States.LOBBY] = {
    [Events.ALL_READY] = States.CHOOSING,
    [Events.RESTART] = States.LOBBY,
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
    if event == Events.RESTART then
      self:restart()
      return
    end
    
    if prevState == States.LOBBY then
      self:newPlayersEnterRound()
      self:updateRound()
      self:freePlayers()
    elseif prevState == States.WAITING and newState ~= States.FINISHED then
      self:newPlayersEnterRound()
      self:updateRound()
    end
  
    if newState == States.REARRANGING then
      self:rearrangePlayers()
      self:startTimer(self.animationTime, function()
        self._stateMachine:send(Events.DELAY_OVER)
      end)
    elseif newState == States.WAITING then
      self:processResults()
      local champion = self:getChampion()
      self:startTimer(self.animationTime, function()
        if champion then
          self._stateMachine:send(Events.GAME_END)
        elseif #self.players.all > #self.playersInRound then
          self._stateMachine:send(Events.NEW_PLAYER)
        else
          self._stateMachine:send(Events.DELAY_OVER)
        end
      end)
    elseif newState == States.CHOOSING then
      self:freePlayers()
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
  self.chosen = setmetatable({}, {__index=function() return 0 end})
  for _, player in ipairs(self.playersInRound) do
    local choice = player.choice
    if choice > maxChoices then
      choice = maxChoices
    end
    self.chosen[choice] = self.chosen[choice] + 1
  end
  local initialY = 0
  local penultimateY = 0.76
  local finalY = 0.935
  for _, player in ipairs(self.playersInRound) do
    local choice = player.choice
    if choice > maxChoices then
      choice = maxChoices
    end
    if self.chosen[choice] == 1 then
      player.score = player.score + self.choices[choice]
      player:gotoPos(player.pos.x, self:getScoreMetersY(player.score), self.animationTime)
    end
  end
end

function GameController:getChampion()
  for _, player in ipairs(self.playersInRound) do
    if player.score >= self.goal then
      self.champion = player
      return player
    end
  end
  self.champion = nil
  return nil
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
  for _, player in ipairs(self.playersInRound) do
    player:gotoPos(player.pos.x, self:getScoreMetersY(player.score), self.animationTime, function() player.dir = 90 end)
  end
end

function GameController:updateRound()
  if not self.players or #self.playersInRound < 3 then
    return
  end
  local nPlayers = #self.playersInRound
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
end

function GameController:restart()
  for _, player in ipairs(self.players.all) do
    player:resetState()
  end
  self.players:rearrangePlayers()
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
    for _, player in ipairs(self.players.all) do
      player.playing = true
    end
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
  if state ~= States.CHOOSING then
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
    message1 = 'To begin, all'
    message2 = 'players must be'
    message3 = 'ready (at least'
    message4 = '3)'
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
  elseif state == States.FINISHED then
    message1 = 'End of game.'
    message2 = 'Congratulations'
    message3 = 'player ' .. string.upper(utils.numberToLetter(self.champion.id)) .. '!'
    message4 = 'You won!'
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

function GameController:drawRestartButton(xScale, yScale, imageXFactor, imageYFactor, fontText)
  love.graphics.setColor(0.4, 0.1, 0.1)
  love.graphics.rectangle('fill', -1.48, 0, 0.45, 0.15, 0.09, 0.03)
  love.graphics.setLineWidth(0.001)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('line', -1.48, 0, 0.45, 0.15, 0.09, 0.03)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(fontText)
  love.graphics.print('RESET', -1.44, 0.13, 0, imageXFactor, -imageYFactor)
end

function GameController:mousePressed(x, y)
  if x >= -1.48 and x <= -1.03 and y >= 0 and y <= 0.15 then
    self._stateMachine:send(Events.RESTART)
  end
end

function GameController:loadChosenButtonImage(path)
  self.chosenButton = Object:new()
  self.chosenButton:loadImage(path)
end

function GameController:loadDarkChosenButtonImage(path)
  self.darkChosenButton = Object:new()
  self.darkChosenButton:loadImage(path)
end

function GameController:loadPointingHandImage(path)
  self.pointingHand = Object:new()
  self.pointingHand:loadImage(path)
end

function GameController:drawResults(xScale, yScale, imageXFactor, imageYFactor, fontChoice, fontMeters)
  if self._stateMachine.state ~= States.WAITING then
    return
  end
  local newMetersY = -0.78
  local pointingHandY = -0.47
  local chosenY = -0.65
  for _, player in ipairs(self.playersInRound) do
      local playerChoice = player.choice
      if playerChoice > #self.choices then
        playerChoice = #self.choices
      end
      if playerChoice > 0 then
    
        self.pointingHand.pos.x = player.pos.x
        self.pointingHand.pos.y = pointingHandY
        self.pointingHand:draw(xScale, yScale, imageXFactor, imageYFactor)
        
        
        local playerScored = self.chosen[playerChoice] == 1
        
        if playerScored then
          self.chosenButton.pos.x = player.pos.x
          self.chosenButton.pos.y = chosenY
          self.chosenButton:draw(xScale, yScale, imageXFactor, imageYFactor)
        else
          self.darkChosenButton.pos.x = player.pos.x
          self.darkChosenButton.pos.y = chosenY
          self.darkChosenButton:draw(xScale, yScale, imageXFactor, imageYFactor)
        end
        
        local adjustX = -0.025
        if playerChoice > 9 then
          adjustX = -0.04
        end
        
        if playerScored then
          love.graphics.setColor(1, 1, 1)
        else
          love.graphics.setColor(0.5, 0.5, 0.5)
        end
        love.graphics.setFont(fontChoice)
        love.graphics.print(tostring(playerChoice), player.pos.x + adjustX, chosenY + 0.04, 0, imageXFactor, -imageYFactor)
        
        if playerScored then
          love.graphics.setColor(0, 0, 0)
          love.graphics.rectangle('fill', player.pos.x - 0.073, newMetersY - 0.08, 0.15, 0.1, 0.03, 0.03)
          love.graphics.setLineWidth(0.01)
          love.graphics.setColor(0.4, 0.1, 0.1)
          love.graphics.rectangle('line', player.pos.x - 0.073, newMetersY - 0.08, 0.15, 0.1, 0.03, 0.03)
          
          local scored = self.choices[playerChoice]
          adjustX = -0.035
          if scored > 99 then
            adjustX = -0.065
          elseif scored > 9 then
            adjustX = -0.055
          end
          love.graphics.setColor(1, 1, 1)
          love.graphics.setFont(fontMeters)
          love.graphics.print('+' .. tostring(scored), player.pos.x+adjustX, newMetersY, 0, imageXFactor, -imageYFactor)
        end
      end
    end
end

return GameController