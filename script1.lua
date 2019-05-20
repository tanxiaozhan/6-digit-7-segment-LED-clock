--[[
--------------------------------------------------
i2c鍒濆鍖栬缃紝GPIO12銆丟PIO14杩炴帴鍒癉S3231瀹炴椂閽熻姱鐗�
--------------------------------------------------
ESP-07 GPIO Mapping
IO index    ESP8266 pin
 ~~~DATA-LENGTH~~~1024~~~DATA-N~~~2~~~DATA-CRC~~~8556~~~DATA-END~~~~~~DATA-START~~~   0 [*]   GPIO16
    1       GPIO5
    2       GPIO4
    3       GPIO0
    4       GPIO2
    5       GPIO14
    6       GPIO12      
    7       GPIO13
    8       GPIO15
    9       GPIO3
    10      GPIO1
    11      GPIO9
    12      GPIO10
[*] D0(GPIO16) can only be used as gpio read/write. 
No support for open-drain/interrupt/pwm/i2c/ow.
--]]

local sclk=4
local lck=2
local sda=1
gpio.mode(sclk,gpio.OUTPUT)
gpio.mode(lck,gpio.OUTPUT)
gpio.mode(sda,gpio.OUTPUT)


gpio.mode(0,gpio.OUTPUT)


if segvar==1 then
    gpio.write(0,gpio.HIGH)
    gpio.write(1,gpio.HIGH)
    gpio.write(2,gpio.HIGH)
    gpio.write(4,gpio.HIGH)
    segvar=0
else
    gpio.write(0,gpio.LOW)
    gpio.write(1,gpio.LOW)
    gpio.write(2,gpio.LOW)
    gpio.write(4,gpio.LOW)
    segvar=1

end