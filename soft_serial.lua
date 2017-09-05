--[[
Software serial - lua transcript -
  * For NodeMCU eLua 5.1
  * won't have send capabilites (but is do-able with gpio.serout)
  * saves data as numbers (int32) , not char
  * Works by external pin interrupts between clk
Created:28/08/17

]]--

soft_serial = { brate=600, rxpin=6, clk_out_pin=1, clk_in_pin=2, --[[txpin=5,]] buffer={}, buffpos=0, timer={} , bitnum=0, bytenum=0, last_bit=0, last_byte=0 , data_flag=false, isreading_flag = false }

--Serial Configuration
function soft_serial.begin (speed)
  if speed then soft_serial.brate = speed end --serial Speed
  --Interrupt mode in rxpin and clk_in_pin
  gpio.mode(soft_serial.rxpin, gpio.INT)
  gpio.mode(soft_serial.clk_in_pin, gpio.INT)
  --clk pin
  gpio.mode(soft_serial.clk_out_pin, gpio.OUTPUT, gpio.PULLUP) --start transmit cb
  --callbacks
  gpio.trig(soft_serial.rxpin, "down", soft_serial.start_read_cb) --start transmit cb
  gpio.trig(soft_serial.clk_in_pin, "both",soft_serial.read_data_cb) --data read cb
  --config last byte
  soft_serial.last_byte = bit.clear(bit.bit(0),0) --empty int32 mask
  soft_serial.bitnum = 0 --set the byte count
  --timer delays
  soft_serial.ser_time1 = math.floor((1000000/speed) * 0.25)
  soft_serial.ser_period = math.floor(1000000/speed)
  print("period:",soft_serial.ser_period,"time1:", soft_serial.ser_time1 )

  soft_serial.ser_time1_mod50 = soft_serial.ser_time1 - soft_serial.ser_time1 % 50
  soft_serial.ser_period_mod50 = soft_serial.ser_period - soft_serial.ser_period % 50
  print("time1 % 50: ",soft_serial.ser_time1_mod50,"period % 50: ", soft_serial.ser_period_mod50)

  local f1 = soft_serial.ser_time1_mod50
  local f2 = soft_serial.ser_period_mod50
  soft_serial.delay_table = {f1,f2,f2,f2,f2,f2,f2,f2,f2}
end

--Read, returns table of numbers
function soft_serial.read ()
  if soft_serial.data_flag == true then
    soft_serial.data_flag = false
    local ret = soft_serial.buffer
    --soft_serial.buffer = {}
    return ret --returns a table of values
  else
    return nil --no data
  end
end

--"startbit" callbackfun
function soft_serial.start_read_cb (level, time)
    gpio.serout(soft_serial.clk_out_pin,gpio.HIGH,soft_serial.delay_table,1,soft_serial.stop_read_cb)
    gpio.trig(soft_serial.rxpin, "none") --deregister start transmit cb
    soft_serial.isreading_flag = true
end --start_read_cb

--data save func
function soft_serial.read_data_cb (level,when)
  soft_serial.last_bit = gpio.read(soft_serial.rxpin)
  if soft_serial.last_bit == 1 then
    soft_serial.last_byte = bit.set(soft_serial.last_byte, soft_serial.bitnum)
  end
  soft_serial.bitnum = soft_serial.bitnum + 1 -- increment the bit count
end

--called at end of packet
function soft_serial.stop_read_cb()
  soft_serial.buffer[soft_serial.buffpos] = soft_serial.last_byte --saves buffer
  soft_serial.buffpos = soft_serial.buffpos + 1 --increment the buffer position
  soft_serial.bitnum = 0 --reset the byte count
  soft_serial.data_flag = true --set data_flag
  soft_serial.isreading_flag = false
  --print('received:', soft_serial.last_byte) --debug message
  soft_serial.last_byte = bit.clear(bit.bit(0),0) --empty int32 mask
  gpio.trig(soft_serial.rxpin, "down", soft_serial.start_read_cb) -- re-registers cb to start_read_cb
end

--EOF
