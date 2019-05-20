srv = net.createServer(net.TCP)

--生成定时设置页面
function setAlarm(alarmNo)
    local tempHtml={}
    tempHtml[1]="<!DOCTYPE html><html>" ..
    "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />" ..
    "<body>" ..
    "<center><h4>定时时间设置</h4><br><br>" ..
    "<form name='f1' method='post' action='index.html'>"
    tempHtml[#tempHtml+1]=
    "<table width='60%' border='0' align='center'>" ..
    "<tr><td width='30%' rowspan='2'>定时<input name='alarmNO' type='text' size='1' value='" .. alarmNo .. "'>　"
    if alarmON[alarmNo][1]==1 then
        tempHtml[#tempHtml+1]="<input type='checkbox' name='chb'checked='checked'>启用</td>"
    else
        tempHtml[#tempHtml+1]="<input type='checkbox' name='chb'>启用</td>"
    end    
    tempHtml[#tempHtml+1]="<td width='79%'>O N:" ..
    "<input name='ONh' type='text' size='1' value='" .. alarmON[alarmNo][2] .. "'>:" ..
    "<input name='ONm' type='text' size='1' value='" .. alarmON[alarmNo][3] .. "'>:" ..
    "<input name='ONs' type='text' size='1' value='" .. alarmON[alarmNo][4] .. "'>　每<input name='ONd' type='text' size='1' value='" .. alarmON[alarmNo][5] .. "'>天</td></tr>"
    tempHtml[#tempHtml+1]="<tr><td>OFF:<input name='OFFh' type='text' size='1' value='" .. alarmOFF[alarmNo][1] .. "'>:" ..
    "<input name='OFFm' type='text' size='1' value='" .. alarmOFF[alarmNo][2] .. "'>:" ..
    "<input name='OFFs' type='text' size='1' value='" .. alarmOFF[alarmNo][3] .. "'></td></tr>"
    tempHtml[#tempHtml+1]="<tr><td colspan='2' align='center'>" ..
    "<br><input type='submit' name='bt' value='提交'></td></tr>" ..
    "</table></form>"
    return tempHtml
end

--生成主页页面
function indexHtml()
    ds3231=require('ds3231')
    local days = {
        [1] = "星期日",
        [2] = "星期一",
        [3] = "星期二",
        [4] = "星期三",
        [5] = "星期四",
        [6] = "星期五",
        [7] = "星期六"
    }

    local second, minute, hour, day, date, month, year = ds3231.getTime()
    
    local currentTime = string.format("%s-%s-%s %s %02d:%02d:%02d", year+2000, month, date, days[day], hour, minute, second)

    ds3231 = nil
    package.loaded["ds3231"]=nil

    local tempHtml={}
    tempHtml[1]="<!DOCTYPE html><html>" ..
        "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><body>" ..
        "<table width='100%' border='0'>" ..
          "<tr><td align='center'>" .. "<h3>ESP8266定时控制器 V1.0</h3><br>" .. "</td></tr>" ..
          "<tr><td align='center'>当前时间：" .. currentTime .. "<br><br></td></tr>" ..
          "<tr><td align='center'>"
    for i=1,5 do
        if alarmON[i][1]==1 then
            tempHtml[#tempHtml+1]="<input name='chk' type='checkbox' checked='checked' disabled='disabled'>"
        else
            tempHtml[#tempHtml+1]="<input name='chk' type='checkbox' disabled='disabled'>"
        end
        tempHtml[#tempHtml+1]="定时" .. i .. "：ON:" .. string.format("%02d",alarmON[i][2]) .. ":" .. 
                                 string.format("%02d",alarmON[i][3]) .. ":" .. 
                                 string.format("%02d",alarmON[i][4]) .. "　每" .. 
                                 string.format("%02s",alarmON[i][5]) .. "天　" .. 
                       "OFF:" .. string.format("%02d",alarmOFF[i][1]) ..  ":" .. 
                                 string.format("%02d",alarmOFF[i][2]) .. ":" .. 
                                 string.format("%02d",alarmOFF[i][3]) .. "　" ..
                                 "<a href='setAlarm.html?editAlarmNo=" .. i .. "'>编辑</a><br><br>"
                                 
    end
    i=nil
     tempHtml[#tempHtml+1]="</td></tr>" ..
        "<tr><td align='center'><br><a href='?OP=open&auto=0'><button>手动开</button></a> 　　　　<a href='?OP=close&auto=0'><button>手动关</button></a></td></tr>"
     tempHtml[#tempHtml+1]=  
        "<tr><td align='center'><br><form name='form1' method='post' action=''>" ..
        "<input type='hidden' id='strDate' name='strDate'>　　　　" ..
        "<input type='button' name='setTime' onclick=genTime(this.form); value=' 校  时 '>" ..
        "</form></td></tr>" ..
        "</table></body></html>"
     tempHtml[#tempHtml+1]="<SCRIPT LANGUAGE='JavaScript'>" ..
        "function genTime(f){" ..
        "var d = new Date();" ..
        "var strD;" ..
        "strD=d.getFullYear() + '-' + (d.getMonth()+1) + '-' + d.getDate() + '-' + (d.getDay()+1) + '-';" ..
        "strD=strD + d.getHours() + '-' + d.getMinutes() + '-' + d.getSeconds() + 'end';" ..
        "document.getElementById('strDate').value=strD;" ..
        "f.submit();}" ..
        "</Script>"
    return tempHtml
end


function receiver(sck, data)

  -- if you're sending back HTML over HTTP you'll want something like this instead
  local response = {"HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/html\r\n\r\n"}
  local  htmlFile=string.match(data,"GET /setAlarm.html")
  if htmlFile then
        htmlFile=string.match(data,"editAlarmNo=%d")
        htmlFile=string.match(htmlFile,"%d")
        if not htmlFile then
            htmlFile=1
        end
        response=setAlarm( tonumber(htmlFile) )
  else
        htmlFile=string.match(data,"alarmNO=%d")
        if htmlFile then
            local n,m
            
            --第n组定时
            htmlFile=string.match(data,"alarmNO=%d")
            n=tonumber(string.match(htmlFile,"%d"))
            local onTime=string.match(data,"ONh=%d+&ONm=%d+&ONs=%d+&ONd=%d+")
            local offTime=string.match(data,"OFFh=%d+&OFFm=%d+&OFFs=%d+")
            
            --设置定时页面中勾选了启用复选框判断
            if string.match(data,"chb=on") then
                alarmON[n][1]=1
            else
                alarmON[n][1]=0
            end
            
            m=1
            for v in string.gmatch(onTime,"%d+") do
                m=m+1
                alarmON[n][m]=tonumber(v)
            end
            interval[n]=alarmON[n][5]
            m=0
            for v in string.gmatch(offTime,"%d+") do
                m=m+1
                alarmOFF[n][m]=tonumber(v)
            end

            --把定时设置保存到文件alarm.dat
            local fc=file.open("alarm.dat","w")
            if fc then
                local alarmInfo
                local i
                for i=1,5 do
                    --生成一行定时数据，格式：ON 1 10:00:00,OFF 10:00:20,interval:1
                    alarmInfo="ON " .. alarmON[i][1] .. " " ..
                                       string.format("%02d",alarmON[i][2]) .. ":" ..
                                       string.format("%02d",alarmON[i][3]) .. ":" ..
                                       string.format("%02d",alarmON[i][4]) .. ",OFF " ..
                                       string.format("%02d",alarmOFF[i][1]) .. ":" ..
                                       string.format("%02d",alarmOFF[i][2]) .. ":" ..
                                       string.format("%02d",alarmOFF[i][3]) .. ",interval:" ..
                                       alarmON[i][5]
                    fc.writeline(alarmInfo)
                end
                fc.close()
                fc=nil
            end

            --返回主页
            response=indexHtml()
        else
            htmlFile=string.match(data,"strDate=%d+-%d+-%d+-%d-%d+-%d+-%d+-%d+")  --浏览器返回的时间格式：yyyy-mm-dd-week-hh-mm-ss
            if htmlFile then
                local dateTime={}
                local n=0
                for v in string.gmatch(htmlFile,"%d+") do
                    n=n+1
                    dateTime[n]=tonumber(v)
                end
                year=dateTime[1]-2000
                month=dateTime[2]
                date=dateTime[3]
                day=dateTime[4]
                hour=dateTime[5]
                minute=dateTime[6]
                second=dateTime[7]
                ds3231=require("ds3231")
                ds3231.setTime(second, minute, hour, day, date, month, year)
                ds3231 = nil
                package.loaded["ds3231"]=nil
                response=indexHtml()
            else
            
                response=indexHtml()
            end
            
            htmlFile=string.match(data,"OP=%a+")
            if htmlFile then
                if string.match(htmlFile,"open") then
                    gpio.write(drvPin,gpio.HIGH)
                else
                    gpio.write(drvPin,gpio.LOW)
                end
                
            else
                response=indexHtml()
            end
        end

  end


  -- sends and removes the first element from the 'response' table
  local function send(localSocket)
    if #response > 0 then
      local tempre=table.remove(response,1)
      localSocket:send(tempre) --table.remove(response, 1))
    else
      localSocket:close()
      response = nil
    end
  end

  -- triggers the send() function again once the first chunk of data was sent
  sck:on("sent", send)

  send(sck)
end

srv:listen(80, function(conn)
  conn:on("receive", receiver)
end)
