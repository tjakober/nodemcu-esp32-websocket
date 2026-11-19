# WebSocket client for NodeMCU-ESP32

A `websocket` module (RFC 6455 **client**) for the [NodeMCU `dev-esp32` firmware](https://github.com/nodemcu/nodemcu-firmware/tree/dev-esp32).
It wraps Espressif's [`esp_websocket_client`](https://github.com/espressif/esp-protocols/tree/master/components/esp_websocket_client)
and offers the same Lua API as the ESP8266 NodeMCU `websocket` module, so existing ESP8266 scripts
need little or no change.

```lua
ws = websocket.createClient()
ws:on("connection", function(ws) ws:send("hello") end)
ws:on("receive",    function(_, msg, opcode) print(msg) end)
ws:on("close",      function(_, status) print("closed", status); ws = nil end)
ws:connect("ws://192.168.1.10:8080/")
```

Full API: [docs/modules/websocket.md](docs/modules/websocket.md).

## Install

The patch applies to the current `dev-esp32` branch (tested against commit `f6c14f2d`, "Add mDNS module").
It adds `components/modules/websocket.c`, the CMake/Kconfig entries, the `esp_websocket_client` dependency and the docs page.

```bash
git clone --branch dev-esp32 --recurse-submodules https://github.com/nodemcu/nodemcu-firmware.git
cd nodemcu-firmware
git apply /path/to/websocket-esp32.patch
./install.sh
# enable the module (menuconfig, or add this line to your sdkconfig):
echo CONFIG_NODEMCU_CMODULE_WEBSOCKET=y >> sdkconfig
make IDF_TARGET=esp32          # or esp32s2, ...
```

Incoming messages larger than `CONFIG_NODEMCU_CMODULE_WEBSOCKET_MAX_MSG` (default 8192 bytes) are dropped.

## Tested

* ESP-IDF 5.3.2, `esp_websocket_client` 1.8.0, Lua 5.1 build.
* **ESP32-S2** (LOLIN S2 Mini), full test plan against a local Node.js `ws` echo server:
  text and binary echo; messages of 6000 and 7500 bytes received complete (reassembled from fragments);
  messages above the limit (9000, 20000 bytes) are dropped with a log line, no crash, connection stays up;
  `ws:close()` gives status `0`; killing the server gives `-19`; unknown host `-5`; unreachable port `-18`;
  an invalid URL raises a Lua error; reconnecting from a timer in the `close` callback works;
  50 connect/close cycles with no heap growth.
* **ESP32** (ESP32-D0WDQ6): connect, register and exchange data with a custom WebSocket server
  (small IoT "things" client: registration, periodic sensor data), running for about an hour; the full test plan
  above was not repeated on this chip.

**Not tested:** `wss://` (TLS), subprotocols, the Lua 5.3 build, other chips (S3, C3, C6).

## Notes

* Pass the URL without trailing whitespace/newlines (e.g. when it was read from a file); the underlying client rejects it.
* `examples/echo-server` is a tiny Node.js echo server (`npm install && node server.js`) used for testing;
  `examples/ws_test.lua` connects with auto-reconnect.

## License

MIT, same as NodeMCU. See [LICENSE](LICENSE).
