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

require('ds3231')

port = 80

days = {
    [1] = "Sunday",
    [2] = "Monday",
    [3] = "Tuesday",
    [4] = "Wednesday",
    [5] = "Thursday",
    [6] = "Friday",
    [7] = "Saturday"
}

months = {
    [1] = "January",
    [2] = "Febuary",
    [3] = "March",
    [4] = "April",
    [5] = "May",
    [6] = "June",
    [7] = "July",
    [8] = "August",
    [9] = "September",
    [10] = "October",
    [11] = "November",
    [12] = "December"
}

srv=net.createServer(net.TCP)
srv:listen(port,
    function(conn)

        second, minute, hour, day, date, month, year = ds3231.getTime()
        prettyTime = string.format("%s, %s %s %s %s:%s:%s", days[day], date, months[month], year, hour, minute, second)

        conn:send("HTTP/1.1 200 OK\nContent-Type: text/html\nRefresh: 5\n\n" ..
            "<!DOCTYPE HTML>" ..
            "<html><body>" ..
            "<b>ESP8266</b></br>" ..
            "Time and Date: " .. prettyTime .. "<br>" ..
            "Node ChipID : " .. node.chipid() .. "<br>" ..
            "Node MAC : " .. wifi.sta.getmac() .. "<br>" ..
            "Node Heap : " .. node.heap() .. "<br>" ..
            "Timer Ticks : " .. tmr.now() .. "<br>" ..
            "</html></body>")
        conn:on("sent",function(conn) conn:close() end)
    end
)
