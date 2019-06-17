local Class = require 'Class'

local StateMachine = Class:extended({
  _initialState = nil,
  _transitions = nil,
  _onTransition = nil,
  state = nil,
})

function StateMachine:constructor(initialState, transitions)
  self._initialState = initialState
  self._transitions = transitions
  self.state = self._initialState
end

function StateMachine:onTransition(transitionCb)
  self._onTransition = transitionCb
end

function StateMachine:send(event)
  local prevState = self.state
  local availableTransitions = self._transitions[self.state]
  if availableTransitions then
    local newState = availableTransitions[event]
    if newState then
      self.state = newState
      if self._onTransition then
        self._onTransition(prevState, event, self.state)
      end
    end
  end
end

return StateMachine