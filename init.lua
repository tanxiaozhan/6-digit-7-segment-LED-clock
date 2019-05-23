---从文件alarm.dat读取定时时间
alarmON={}       --定时开启时间，格式：启用标志（1-启用，0-不启用），时，分，秒，重复间隔天数
alarmOFF={}      --定时关闭时间，格式：时，分，秒
interval={}      --间隔天数
--seg={0xbe,0x0c,0x76,0x5e,0xcc,0xda,0xfa,0x0e,0xfe,0xde}
--[[
    a
   ---
 b|   |f
   -g-
 c|   |e
   ---
    d

74HC595的Q0-Q7连接数码管如下：
Q0---->:  PM  ON  其中第三片595Q0接:的上面一个点，第四片接:的下面点
          第二片接PM，第一片接ON
Q1---->a
Q2---->f
Q3---->e
Q4---->d
Q5---->c
Q6---->g
Q7---->b
--]]

--当前日期、时间，初始化为2018-1-1 0:0:0 星期日
second, minute, hour, day, date, month, year=0,0,0,1,1,1,18
iflag=0
local strAlarm,temp,i

--初始化定时时间
for i=1,5
do 
    alarmON[i]={}    --二维数组
    alarmON[i][1]=0
    alarmON[i][2]=0
    alarmON[i][3]=0
    alarmON[i][4]=0
    alarmON[i][5]=0
    interval[i]=0

    alarmOFF[i]={}   --创建二维数组
    alarmOFF[i][1]=0
    alarmOFF[i][2]=0
    alarmOFF[i][3]=0
end

if file.open("alarm.dat","r") then
    i=0
    strAlarm=file.readline()
    while(strAlarm)
    do
       i=i+1
       --获得定时开时间，格式：ON 定时启用标志（1-启用，0-不启用） 时:分:秒 replea:间隔天数
       temp=string.match(strAlarm,"ON %d %d+:%d+:%d+")

       alarmON[i][1]=tonumber(string.sub(temp,4,4))
       alarmON[i][2]=tonumber(string.sub(temp,6,7))
       alarmON[i][3]=tonumber(string.sub(temp,9,10))
       alarmON[i][4]=tonumber(string.sub(temp,12,13))
       temp=string.match(strAlarm,"interval:%d+")
       alarmON[i][5]=tonumber(string.match(temp,"%d+"))
       interval[i]=alarmON[i][5]
       
       --获得定时关闭时间，格式：OFF 时:分:秒
       temp=string.match(strAlarm,"OFF %d+:%d+:%d+")
       alarmOFF[i][1]=tonumber(string.sub(temp,5,6))
       alarmOFF[i][2]=tonumber(string.sub(temp,8,9))
       alarmOFF[i][3]=tonumber(string.sub(temp,11,12))
       
    strAlarm=file.readline()
    end
    file.close()
end

--[[
--------------------------------------------------
i2c初始化设置，GPIO12、GPIO14连接到DS3231实时钟芯片
--------------------------------------------------
ESP-07 GPIO Mapping
IO index    ESP8266 pin
    0 [*]   GPIO16
    1       GPIO4
    2       GPIO5
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
ds3231=require("ds3231")
local SDA, SCL = 5, 6
i2c.setup(0, SDA, SCL, i2c.SLOW) -- call i2c.setup() only once
local alarmId=1   --DS3231定时1
ds3231.setAlarm(alarmId,ds3231.EVERYSECOND)
--ds3231.enableAlarm(alarmId)
second, minute, hour, day, date, month, year = ds3231.getTime()

-- Get current time
print(string.format("Time & Date: %s:%s:%s %s-%s-%s", hour, minute, second, year+2000, month, date))


alarmId=nil
-- 使用后释放ds3231模块
ds3231 = nil
package.loaded["ds3231"]=nil

------------------------------------------------
--
--设置pin1(GPIO13)为外部中断输入端
--
------------------------------------------------
local pin = 7
gpio.mode(pin,gpio.INT)
local sclk=4
local lck=1
local sda=2
gpio.mode(sclk,gpio.OUTPUT)
gpio.mode(lck,gpio.OUTPUT)
gpio.mode(sda,gpio.OUTPUT)
gpio.mode(0,gpio.OUTPUT)

local function disp()

    local seg={0xbe,0x0c,0x76,0x5e,0xcc,0xda,0xfa,0x0e,0xfe,0xde}
    local i,j
    --local segTemp
    local realTime={}
    local segBits={}   --把7段码转换为8位二进制，每个数组元素保存一位二进制
    realTime[1]=math.floor(hour/10)
    realTime[2]=hour % 10
    realTime[3]=math.floor(minute/10)
    realTime[4]=minute % 10
    realTime[5]=math.floor(second/10)
    realTime[6]=second % 10
   
    --gpio.write(sda,gpio.LOW)
    gpio.write(lck,gpio.LOW)
    
    --local segTemp
    for i=1,6 do
        realTime[i]= seg[ realTime[i] + 1]
        --segTemp = seg[ realTime[i] +1 ]
        
        --把一个字节转换为八位二进制，存放到segBits数组
        for j=1,8 do
           segBits[j] = realTime[i] % 2
           realTime[i] = math.floor(realTime[i] /2)
           
           --segBits[j]= segTemp % 2
           --segTemp = math.floor(segTemp /2)
        end

        --增加小时和分钟之间的冒号（：），由中间二片595的Q0控制
        --对应段码中的最低位，即segBits数组中的segBits[1]
        if (i==3 or i==4) then
            segBits[1]=1
        end
        
        --输出八位二进制到74HC595
        for j=8,1,-1 do
            gpio.write(sclk,gpio.LOW)
            if  segBits[j]==1 then
                gpio.write(0,gpio.HIGH)
            else
                gpio.write(0,gpio.LOW)
            end
            gpio.write(sclk,gpio.HIGH)   --595时钟上上升沿，595移位寄存器移动一位
        end
    end
    
    --gpio.write(sda,gpio.HIGH)
    gpio.write(lck,gpio.HIGH)     --595锁存，595移位寄存器的值锁存到输出寄存器，从Q0-Q7输出
end


local function getTimeDS3231(level)
    local alarmId=1
    ds3231=require("ds3231")
    second, minute, hour, day, date, month, year = ds3231.getTime()

    print(string.format("Time & Date: %s:%s:%s %s-%s-%s", hour, minute, second, year+2000, month, date))

    disp()     --显示时间
--]]
    --与5组定时时间比较
 --[[    gpio.write(0,gpio.HIGH)
    gpio.write(1,gpio.HIGH)
    gpio.write(2,gpio.E:M 1032E:M 1032E:M 1032HIGH)
    gpio.write(4,gpio.HIGH)
    segvar=0
 
    
    local i
    for i=1,5 do
        --该组定时启用，则比较时间
        if alarmON[i][1]==1 then
            --根据定时时间打开继电器
            if (alarmON[i][2]==hour) and (alarmON[i][3]==minute) and (alarmON[i][4]==second) then
                --间隔天数为1，继电器通电闭合
                if interval[i]<=1 then
                    gpio.write(drvPin, gpio.HIGH)  --GPIO4输出高电平，继电器吸合
                    interval[i]=alarmON[i][5]   --重装间隔天数
                else
                    interval[i]=interval[i]-1   --间隔天数减1
                end
            end

            --根据定时时间关闭继电器
            if (alarmOFF[i][1]==hour) and (alarmOFF[i][2]==minute) and (alarmOFF[i][3]==second) then
                    gpio.write(drvPin,gpio.LOW)  --GPIO4输出低电平，继电器关闭
            end    
        end
    end
--]]
    --print(string.format("Date & Time: %s-%s-%s %s:%s:%s", year+2000,month,date,hour, minute, second))

    ds3231.reloadAlarms(alarmId)
    
    alarmId,i=nil,nil
    -- 使用后释放ds3231模块
    ds3231 = nil
    package.loaded["ds3231"]=nil
    
end

--设置下降沿中断及中断处理函数
gpio.trig(pin, "down", getTimeDS3231)

--wifi设置
dofile("wifi.lua")
--启用http服务
dofile("httpServer.lua")
--dofile("telnet.lua")
