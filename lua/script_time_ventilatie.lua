 script_time_ventilatie.lua
-- script written by Tweakers.net user 'ThinkPad' for forummember 'M.v.Veelen'
-- See also this forumpost: http://gathering.tweakers.net/forum/list_message/44783606#44783606
local TempHumSensor = 'Cv-warmwater' 

commandArray = {}
if (devicechanged[TempHumSensor]) then -- Only run rest of script when above sensor is updated in Domoticz

local PipeTemperatureSensor = 'Cv-warmwaterr' --NAME of the virtual sensor that only contains temperature
local TriggerTemperature = 45 --temperature of hotwater pipe where fan should start running
local LowerTriggerTemperature = 35 --temperature of hotwater pipe where fan should STOP running
local FanSwitch = 'Badkamer_fan' --name of switch that controls the fan
local BathroomLightswitch = 'Badkamer_fan' --name of switch of bathroomlight
local FanStandardRuntime = 1800 --time (seconds) that fan should run each shower session, 1800 seconds, half an hour
local FanMaxRuntime = 3600 --time (seconds) that fan should run at max before it is stopped (to prevent running endlessly), 3600 seconds, 1 hour
local TempOnlySensor = 4559 --idx of the virtual temperature sensor where you want to store only temperature in
DEBUG_MODE = false --set to 'true' (without quotes) if you want to see more messages in Domoticz log

print('<font color=#2E9AFE>=========== Ventilatiescript ============</font>')   

sTemp, sHumidity = otherdevices_svalues[TempHumSensor]:match("([^;]+);([^;]+)")
sTemp = tonumber(sTemp);
sHumidity = tonumber(sHumidity);
commandArray[1] = {['UpdateDevice'] = TempOnlySensor .. '|0|' .. sTemp}
 
--Function to get timedifference (in seconds) since fan has started
function timedifference(s)
   year = string.sub(s, 1, 4)
   month = string.sub(s, 6, 7)
   day = string.sub(s, 9, 10)
   hour = string.sub(s, 12, 13)
   minutes = string.sub(s, 15, 16)
   seconds = string.sub(s, 18, 19)
   t1 = os.time()
   t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
   difference = os.difftime (t1, t2)
   return difference
end

if DEBUG_MODE == true then 
print('<b style="color:Blue">=========== Ventilatiescript ============</b>')   
print('Sensorname:  ' .. PipeTemperatureSensor)
print('TriggerTemperature  ' .. TriggerTemperature)
print('Ondergrens  ' .. LowerTriggerTemperature)
print('Huidige leidingtemperatuur: ' .. sTemp)
print('Naam fanschakelaar  ' .. FanSwitch)
print('Lichtschakelaar badkamer  ' .. BathroomLightswitch)
print('Nalooptijd  ' .. FanStandardRuntime)
print('Max looptijd fan  ' .. FanMaxRuntime)
--print('Fan ingeschakeld' ..difference 'sec geleden')
end

difference = timedifference(otherdevices_lastupdate[FanSwitch])

--Turn fan off if someone is showering, turn fan off if conditions become valid
if otherdevices[BathroomLightswitch] == 'On' and otherdevices[FanSwitch] == 'Off' and otherdevices_temperature[PipeTemperatureSensor] >= tonumber (TriggerTemperature) then --someone is showering, turn fan on
        commandArray[FanSwitch]='On'
print('<b style="color:Blue">Badkamerlicht is aan, fan is uit, leiding warm genoeg ---> fan aanzetten</b>') 
elseif otherdevices[FanSwitch] == 'On' and otherdevices_temperature[PipeTemperatureSensor] <= tonumber (LowerTriggerTemperature) and (difference > FanStandardRuntime) then --fan is running but pipe has cooled down below minThreshold and fan has been running for 30min, turn fan off
   commandArray[FanSwitch]='Off'
print('<b style="color:Blue">Fan is aan, maar warmwaterleiding afgekoeld en fan heeft nalooptijd erop zitten ---> Fan uitzetten</b>') 
elseif otherdevices[FanSwitch] == 'On' and (difference > FanMaxRuntime) then --Fan has exceeded max runtime, turn fan off
   commandArray[FanSwitch]='Off'
print('<b style="color:Blue">Fan is aan, maar maximum draaitijd is verstreken ---> Fan uitzetten</b>')
end 

end --end of first 'if' line

return commandArray