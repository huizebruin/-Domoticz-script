--- /home/pi/domoticz/scripts/lua/script_time_upload_to_PVoutput_WP.lua
-- This script collects the values below from Domoticz.
-- And uploads all of the values to a PVoutput account.
--
-- For more information about PVoutput, see their user documentation on http://www.pvoutput.org/help.html
----------------------------------------------------------------------------------------------------------
-- Written by Alphons Uijtdehaag (AUijtdehaag) 2017
-- Based on: http://www.domoticz.com/wiki/Upload_energy_data_to_PVoutput
-- Before u can use the script, read instructions on the Domoticz website to Install the Lua socket library
----------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------
-- Domoticz IDX of devices
----------------------------------------------------------------------------------------------------------
local WPDeviceName = "Solar Power" -- Name of the energy device that shows Consumption
--local OutsideTemperatureDeviceName = "temp buiten voor" -- Name of the energy device that shows Outside Temperature
--local CurrentTemperatureDevicename = "temp buiten voor" -- actueel buiten temp

----------------------------------------------------------------------------------------------------------
-- PVoutput parameters
----------------------------------------------------------------------------------------------------------
local PVoutputApi = "2ce2375a0565a5cb77678e89e7e77e1b19891ab6" -- Your PVoutput api key
local PVoutputSystemID = "45672" -- Your PVoutput System ID45672
local PVoutputPostInterval = 5 -- The number of minutes between posts to PVoutput (normal is 5 but when in donation mode it's max 1)
local PVoutputURL = '://pvoutput.org/service/r2/addstatus.jsp?key=' -- The URL to the PVoutput Service

----------------------------------------------------------------------------------------------------------
-- Require parameters
----------------------------------------------------------------------------------------------------------
local http = require("socket.http")
--local http = require('rubbish')
----------------------------------------------------------------------------------------------------------
-- Script parameters
----------------------------------------------------------------------------------------------------------
EnergyGeneration = 0 -- v1 in Watt hours
PowerGeneration = 0 -- v2 in Watts
--OutsideTemperature = 0
--OutsideRV = 0
c1 = 1 -- c1 = 0 when v1 is today's energy. c1 = 1 when v1 is lifetime energy.
Debug = "YES" -- Turn debugging on ("YES") or off ("NO")


----------------------------------------------------------------------------------------------------------
-- Lua Functions
----------------------------------------------------------------------------------------------------------
function UploadToPVoutput(self)
b, c, h = http.request("http" .. PVoutputURL .. PVoutputApi .. "&sid=".. PVoutputSystemID .. "&d=" .. os.date("%Y%m%d") .. "&t=" .. os.date("%H:%M") ..

"&v1=" .. EnergyGeneration .. "&v2=" .. PowerGeneration .. "&c1=" .. c1 )

-- Original:
-- b, c, h = http.request("http" .. PVoutputURL .. PVoutputApi .. "&sid=".. PVoutputSystemID .. "&d=" .. os.date("%Y%m%d") .. "&t=" .. os.date("%H:%M") ..

-- "&v1=" .. EnergyGeneration .. "&v2=" .. PowerGeneration .. "&v3=" .. EnergyConsumption .. "&v4=" .. PowerConsumption .. "&v5=" .. CurrentTemp .. "&v6=" .. Voltage .. "&c1=" .. c1 )

if b=="OK 200: Added Status" then
print(" --- Current WP status successfully uploaded to PVoutput.")
else
print(" --- " ..b)
end
if Debug=="YES" then
print(" --- Energy Generation (v1) = " .. EnergyGeneration .. " Wh")
print(" --- Power Generation (v2) = " .. PowerGeneration .. " W")
--print(" --- Outside Temperature (v5) = " .. OutsideTemperature .. " C")
print(" --- Cumulative Flag (c1) = " .. c1 .. "")
end
end

function update(device, id, power, energy, index)
commandArray[index] = {['UpdateDevice'] = id .. "|0|" .. power .. ";" .. energy}
end

----------------------------------------------------------------------------------------------------------
-- CommandArray
----------------------------------------------------------------------------------------------------------
commandArray = {}
time = os.date("*t")
if PVoutputPostInterval>1 then
TimeToGo = PVoutputPostInterval - (time.min % PVoutputPostInterval)
print('--- Tijd tot de volgende Upload naar PVoutput: ' ..TimeToGo.. " minuten")
end
if((time.min %  PVoutputPostInterval)==0)then


-- Generation
PowerGeneration, EnergyGeneration = otherdevices_svalues[WPDeviceName]:match("([^;]+);([^;]+)")
--OutsideTemperature, OutsideRV = otherdevices_svalues[OutsideTemperatureDeviceName]:match("([^;]+);([^;]+)")

-- Upload data to PVoutput
UploadToPVoutput()

if Debug=="YES" then
print(" ---- The total generated energy is " .. EnergyGeneration .. " Wh");
print(" ---- The current generated power is " .. PowerGeneration .. " W");
--print(" ---- The outside temperature is " .. OutsideTemperature .. " C");
--print(" ---- The Outside RV is " .. OutsideRV .. " %");
end
end

return commandArray