local onTime="ONh=20&ONm=43&ONs=20&ONd=1"
local offTime="OFFh=20&OFFm=43&OFFs=50"
local m,n=1,2
local drvPin=2
gpio.mode(drvPin, gpio.OUTPUT)
alarmON[n][1]=1
            for v in string.gmatch(onTime,"%d+") do
                m=m+1
                print("v=" .. v)
                alarmON[n][m]=tonumber(v)
            end
            m=0
            for v in string.gmatch(offTime,"%d+") do
                m=m+1
                print("v=" .. v)
                alarmOFF[n][m]=tonumber(v)
            end
alarmON[n][4]=second
alarmOFF[n][3]=second+20
interval[n]=alarmON[n][5]
    local i
    for i=1,5 do
        --该组定时启用，则比较时间
        if alarmON[i][1]==1 then
            --根据定时时间打开继电器
            print("i=" .. i)
            if (alarmON[i][2]==hour) and (alarmON[i][3]==minute) and (alarmON[i][4]==second) then
                --间隔天数为1，继电器通电闭合
                print("hhmmss:" .. i)
                if interval[i]==1 then
                    print("alarm is on")
                    gpio.write(drvPin, gpio.HIGH)  --GPIO4输出高电平，继电器吸合
                    interval[i]=alarmON[i][5]   --重装间隔天数
                else
                    interval[i]=interval[i]-1   --间隔天数减1
                end
            end

            --根据定时时间关闭继电器
            if (alarmOFF[i]==hour) and (alarmOFF[i]==minute) and (alarmOFF[i]==second) then
                    gpio.write(drvPin,gpio.LOW)  --GPIO4输出低电平，继电器关闭
            end    
        end
    end


--[[
do
  -- use pin 1 as the input pulse width counter
  local pin, pulse1, du, now, trig = 1, 0, 0, tmr.now, gpio.trig
  gpio.mode(pin,gpio.INT)
  local function pin1cb(level, pulse2)
    print( level, pulse2 - pulse1 )
    pulse1 = pulse2
    trig(pin, level == gpio.HIGH  and "down" or "up")
  end
  trig(pin, "down", pin1cb)
end
--]]
