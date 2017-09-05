# software serial for lua
## Description
##### Software serial for the [Nodemcu](https://github.com/nodemcu/nodemcu-firmware)
Currently uses the [bit](https://github.com/nodemcu/nodemcu-firmware/blob/master/docs/en/modules/bit.md) and [gpio](https://github.com/nodemcu/nodemcu-firmware/blob/master/docs/en/modules/gpio.md) modules. works by setting a calback in the `rx_pin` lisstening for the start bit of a char, then a assincronous `gpio.serout()` generates a square wave at a prede at a predefined pin, that is connected to some other pin, that has a callback that reads the serial data t
## Features and Non-features
* serial interface in any pin 
* **No TX yet**, because wasn't required for it's original use, but is easy to implement
* Saves data as int32, because the [bit](https://github.com/nodemcu/nodemcu-firmware/blob/master/docs/en/modules/bit.md) library uses int32 as masks
* no object model (too slow)
## Observations
* only tested under light load (600 baud/s, no other loads) and it works by itself, but might need some adjusting/not work when the MCU is under heavy load
* needs external wiring 
