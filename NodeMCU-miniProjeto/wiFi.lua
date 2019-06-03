local wiFi = {}

function obtainGotIp(cbAfter)
  cbAfter = cbAfter or nil
  return function (info)
    print ("Connection succeeded. IP: ", info.IP)
    cbAfter()
  end
end

function disconnected(info)
  print("Connection error: ", info.reason)
end

function wiFi.connect(ssid, pass, successCb)
  wiFiConfig = {
    ssid = ssid,
    pwd = pass,
    got_ip_cb = obtainGotIp(successCb),
    disconnected_cb = disconnected,
    save = false
  }
  wifi.setmode(wifi.STATION)
  wifi.sta.config(wiFiConfig)
end

return wiFi