local telegram = {}

local chatId = '649752449'
local botToken = '824200008:AAEqbmGqowkDoXR7nMZ9_ySCnVyzuTcXA_Y'

local baseUrl = 'https://api.telegram.org/bot' .. botToken
local paths = {
  sendMessage = '/sendMessage'
}

function telegram.sendMessage(msg)
  local url = baseUrl .. paths.sendMessage
  local headers = 'Content-Type: application/json\r\n'
  local body = [[
    {
      "chat_id": "{{chatId}}",
      "text": "{{msg}}"
    }
  ]]
  body = string.gsub(body, '{{chatId}}', chatId)
  body = string.gsub(body, '{{msg}}', msg)
  http.post(url, headers, body)
end

return telegram