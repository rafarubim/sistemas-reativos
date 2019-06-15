package.loaded.wiFi = nil
local wiFi = require 'wiFi'
package.loaded.httpServer = nil
local httpServer = require 'httpServer'
--package.loaded.telegram = nil
--local telegram = require 'telegram'

local googleAssistantServer = {}

local function trim(str)
  str = str or ''
  local _, _, startTrimmed = string.find(str, '^%s*(%S.*)$')
  local _, _, trimmed = string.find(startTrimmed, '^(.*%S)%s*$')
  if trimmed == null then
    return ''
  end
  return trimmed
end

local answerCbs = {}

function googleAssistantServer.subscribeCbAnswer(cb)
  answerCbs[#answerCbs+1] = cb
end

local function answerPage(req)
  req.body = req.body or ''
  local _, _, answer = string.find(req.body, '"answer"%s-:%s-"(.-)"')
  if answer then
    answer = trim(answer)
    for _, cb in ipairs(answerCbs) do
      cb(answer)
    end
  end

  return httpServer.okResponse()
end

httpServer.route('/answer', answerPage)

function googleAssistantServer.open(openedCb)
  local function internetConnected()
    httpServer.start(openedCb)
  end
  print('Beginning connection...')
  wiFi.connect('Rafa', 'rafagato', internetConnected)
end

return googleAssistantServer