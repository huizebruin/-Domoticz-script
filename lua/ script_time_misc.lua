-- script_time_misc.lua
-------------------------------------
-- Declaratiof variables
local schakeltijd = 0
local uur = tonumber(os.date("%H"));
local min = tonumber(os.date("%M"));
local LuxAchter = tonumber(otherdevices_svalues['Lux Sensor-woonkamer'])  --LUX in woonkamer
local Luxtuin = tonumber(otherdevices_svalues['ldr-overkapping'])  --LUX buiten tuin
local zononder  = timeofday['SunsetInMinutes']+30
local nu = uur*60+min
local verschil = zononder - nu
local dag = tostring(os.date("%a"));


commandArray = {}

--local function bathroomHum()
	-- Do something here
--end

--local function warnComputerTimeExceeded()
	-- Do something here
--end

local m = os.date('%M')
if (m % 5 == 0) then
print('      De 5 minuten buiten_verlichting script')
if (otherdevices['Automatisch Licht']=='On') then
if (Luxtuin <= 90 and otherdevices ) then 
    commandArray['buiten-1-led']='On' 
    commandArray['buiten-3-overkapping']='On' 
	commandArray['Voordeur Verlichting']='On' 
end
end
end

local m = os.date('%M')
if (m % 5 == 0) then
print('      Huiskamer verlichting script')
if (otherdevices['Automatisch Licht_woonkamer']=='On') then
if (LuxAchter <= 160 and otherdevices ) then 
    commandArray['Woonkamer-Achter']='On' 
    commandArray['Woonkamer-Voor']='On'
	commandArray['Woonkamer-Midden']='On'
	commandArray['Staande lamp of Kerstboom']='On'
	commandArray['woonkamer rechts voor bol']='On'
	end
end
end




--if (m % 10 == 0) then
	-- print('The 10 minute script interval reached')
	-- Call your function here that shall run every 10 minutes
--end
--if (m % 30 == 0) then
	-- print('The 30 minute script interval reached')
	-- Call your function here that shall run every 30 minutes
--end
--if (m % 60 == 0) then
	-- print('The 60 minute script interval reached')
	-- Put your script code here that shall run every 60 minutes
	--warnComputerTimeExceeded()
--end

return commandArray