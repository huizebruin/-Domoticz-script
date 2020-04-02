-- Ping script by huizebruin.nl 
-- www.huizebruin.nl

function DevicePing(ip, device)
    ping_success=""
    ping_success=os.execute('ping -c1 -w1 ' .. ip)
    if ping_success then
        print("ping success " ..device)
        DeviceOnOff('On',device)
    else
        print("ping fail " ..device)
        DeviceOnOff('Off',device)
    end
 
end

function DeviceOnOff(Action, device)
    
    local deviceValue = otherdevices[device]
    
    if deviceValue ~= Action then
        commandArray[device] = Action
    end
end
    
commandArray = {}
print("*****************   start pingen     *******************")
DevicePing('IP ADRES','APPARAAT 1')
DevicePing('IP ADRES','APPARAAT 2')
 
print("*****************   end pingen     *******************")