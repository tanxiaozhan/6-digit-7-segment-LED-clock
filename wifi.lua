-- 开启 Wifi，并设置为AP模式
--connect to Access Point (DO save config to flash)
local mac
local ap_cfg={}
mac=wifi.ap.getmac()
ap_cfg.ssid="ESP8266_" .. 
        string.sub(mac,10,11) .. 
        string.sub(mac,13,14) ..
        string.sub(mac,16,17) 
ap_cfg.pwd="12345678"

wifi.setmode(wifi.SOFTAP)

wifi.ap.config(ap_cfg)

ap_cfg.ip="192.168.16.1"
ap_cfg.netmask="255.255.255.0"

wifi.ap.setip(ap_cfg)


--开户wifi，设置为station模式
--[[
station_cfg={}
local home=true
if home then
    station_cfg.ssid="TRouter_4G"
    station_cfg.pwd="EinstTianchen#1974"
else
    station_cfg.ssid="UTT-HIPER_ce8be8"
    station_cfg.pwd="!jsjx2013"
end

local station_cfg={}
local home=true
if home then
    station_cfg.ssid="TRouter_4G"
    station_cfg.pwd="EinstTianchen#1974"
else
    station_cfg.ssid="UTT-HIPER_ce8be8"
    station_cfg.pwd="!jsjx2013"
end

station_cfg.save=true

ip=wifi.sta.getip()
print(ip)
if not ip then
    wifi.sta.config(station_cfg)
    print(wifi.sta.getip())
end
station_cfg.save=true

ip=wifi.sta.getip()
print(ip)
if not ip then
    wifi.setmode(wifi.STATION)
    wifi.sta.config(station_cfg)
    print(wifi.sta.getip())
end
--]]
