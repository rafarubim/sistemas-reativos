package.loaded.espio = nil
local espio = require 'espio'
package.loaded.googleAssistantServer = nil
local googleAssistantServer = require 'googleAssistantServer'

local quizStates = {
  IDLE = 1,
  QUESTION = 2,
  FINISHED = 3
}

local quizEvents = {
  START = 0,
  ASK = 1,
  ANSWER = 2,
  RESET = 3
}

local questions = {"In which country was the hot-dog invented?","What percent of the world population is left-handed (answer only the number)?",
"What's the world's biggest country?","Butterflies have around 12000 eyes.","What is the maximum depth of an ocean, in meters (answer only the number)?"}

local possibleAnswers = {{"Germany","Austria"},{"30","10"},{"Russia","Canada"},{"True","False"},{"20000","11000"}}

local correctAnswers = {"Germany","10","Russia","True","11000"}

local currentQuestion = 1

local currentState = nil

local score = 0

local transitions = {
  [quizStates.IDLE] = function (event)
    if event == quizEvents.ASK then
      return quizStates.QUESTION
    elseif event == quizEvents.RESET then
      score = 0
      currentQuestion = 1
      return quizStates.IDLE
    end
  end,
  [quizStates.QUESTION] = function (event, data)
    if event == quizEvents.ANSWER then
      print('Answer: ' .. data)
      if data:lower() == correctAnswers[currentQuestion]:lower() then
        score = score + 1
        print ('Correct!')
        espio.greenBlinkOnce()
      else
        print('Incorrect!')
        espio.redBlinkOnce()
      end
      currentQuestion = currentQuestion + 1
      if currentQuestion > #questions then
        return quizStates.FINISHED
      else
        return quizStates.IDLE
      end
    elseif event == quizEvents.RESET then
      score = 0
      currentQuestion = 1
      return quizStates.IDLE
    end
  end,
  [quizStates.FINISHED] = function (event)
    if event == quizEvents.RESET then
      score = 0
      currentQuestion = 1
      return quizStates.IDLE
    end
  end
}

local function makeTransition(event, data)
  local nextState
  if currentState == nil and event == quizEvents.START then
    nextState = quizStates.IDLE
  elseif currentState ~= nil then
    nextState = transitions[currentState](event, data)
  end
  if nextState ~= nil then
    currentState = nextState

    if currentState == quizStates.IDLE then
      print('Press the button for the next question')
    elseif currentState == quizStates.QUESTION then
      print(questions[currentQuestion])
      local options = possibleAnswers[currentQuestion]
      print(options[1] .. ' or ' .. options[2] .. '?')
    elseif currentState == quizStates.FINISHED then
      print('End of the quiz! You got ' .. score .. ' out of ' .. #questions .. ' right answers. Press the other button to play again')
    end
  end
end

espio.subscribeCbButton1(function()
  makeTransition(quizEvents.ASK)
end)

espio.subscribeCbButton2(function()
  makeTransition(quizEvents.RESET)
end)

googleAssistantServer.subscribeCbAnswer(function(answer)
  makeTransition(quizEvents.ANSWER, answer)
end)

googleAssistantServer.open(function()
  makeTransition(quizEvents.START)
end)