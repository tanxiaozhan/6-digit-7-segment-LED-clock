
local fc=file.open("alarm.dat","w")
if fc then
    fc.writeline("ON 1 10:00:00,OFF 10:00:20,replea:10")
    fc.writeline("ON 0 12:00:00,OFF 12:00:02,replea:20")
    
    fc.close()
    fc=nil
end
