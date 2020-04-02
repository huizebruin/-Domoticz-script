--Initilise a command array
commandArray={}

-----------------------------------------------------
-- Lux Level Script
-----------------------------------------------------
if tonumber(otherdevices['Lux Sensor-woonkamer']) <= 200 then
if ( uservariables["LightLevel"] == "day") then
commandArray['Variable:LightLevel']= "night"
commandArray['SendNotification']='Lux#Light Levels Low#0'
end
else
print("=====================================================")
print('Lux level >>> ' .. otherdevices['Lux Sensor-woonkamer'])
print("=====================================================")

if ( uservariables["LightLevel"] == "night") then
commandArray['Variable:LightLevel']= "day"
commandArray['SendNotification']='Lux#Light Levels High#0'
end
end
return commandArray 