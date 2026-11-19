-- ws_test.lua: exercises the websocket module on NodeMCU-ESP32.
-- Edit SSID, PASS and URL first, then run on the board: dofile("ws_test.lua")

local SSID = "MyWiFi"
local PASS = "secret"
local URL  = "ws://192.168.1.10:8080/"   -- e.g. the echo server in examples/echo-server

local ws
local reconnect_timer = tmr.create()

local function start_ws()
  ws = websocket.createClient()
  ws:config({ headers = { ['User-Agent'] = 'NodeMCU-ESP32' }, ping_interval = 20 })

  ws:on("connection", function(c)
    print("[ws] connected")
    c:send('{"type":"hello"}')
  end)

  ws:on("receive", function(_, msg, opcode)
    print("[ws] received (" .. opcode .. "): " .. msg)
  end)

  ws:on("close", function(_, status, code)
    print("[ws] closed, status=" .. status .. (code and (" code=" .. code) or ""))
    ws = nil
    -- reconnect after 5 s (the library deliberately does not reconnect by itself)
    reconnect_timer:alarm(5000, tmr.ALARM_SINGLE, start_ws)
  end)

  print("[ws] connecting to " .. URL)
  ws:connect(URL)
end

wifi.mode(wifi.STATION)
wifi.sta.config({ ssid = SSID, pwd = PASS }, false)
wifi.sta.on("got_ip", function(_, info)
  print("[wifi] IP " .. info.ip)
  start_ws()
end)
wifi.start()
wifi.sta.connect()
