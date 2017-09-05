# software serial for lua
## Description
##### Software serial for the [Nodemcu](https://github.com/nodemcu/nodemcu-firmware)
Works by setting a calback in the `rx_pin` listening for the start bit of a char.
when called it uses `gpio.serout()`, to generate a square wave  at `clk_out_pin`,that is connected to `clk_in_pin`, that has a read callback attached to it (that read the actual serial data in `rx_pin`).
**I Know, this is contrived** but i hadn't a better at the time to bypass the limitation of min 1ms in the `tmr` module
## Features and Non-features
* serial interface in any pin (except D0, it does not supports calbacks)
* **No TX yet**, because wasn't required for it's original use, but is easy to implement
* Saves data as int32, because the [bit](https://github.com/nodemcu/nodemcu-firmware/blob/master/docs/en/modules/bit.md) library uses int32 as masks
* no object model (too slow)
## Observations
* only tested under light load (600 baud/s, no other loads) and it works by itself, but might need some adjusting/not work when the MCU is under heavy load
* Needs external wiring 
* Currently uses the [bit](https://github.com/nodemcu/nodemcu-firmware/blob/master/docs/en/modules/bit.md) and [gpio](https://github.com/nodemcu/nodemcu-firmware/blob/master/docs/en/modules/gpio.md) modules
* for adjusting purposes, have in mind that the callback overhead is ~2 ms
