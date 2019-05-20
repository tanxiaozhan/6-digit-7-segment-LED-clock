-- ESP-07 GPIO Mapping
--[[
IO index    ESP8266 pin
    0 [*]   GPIO16
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

SDA, SCL = 6, 5
i2c.setup(0, SDA, SCL, i2c.SLOW) -- call i2c.setup() only once

require("ds3231")

second, minute, hour, day, date, month, year = ds3231.getTime();

-- Get current time
print(string.format("Time & Date: %s:%s:%s %s/%s/%s", hour, minute, second, date, month, year))

-- Don't forget to release it after use
ds3231 = nil
package.loaded["ds3231"]=nil
