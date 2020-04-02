    -- /home/pi/domoticz/scripts/lua/script_time_upload_to_PVoutput.lua
    -- This script collects the values below from Domoticz
    -- * The Power generation, energy generation and voltage from a Solar power inverter
    -- * The temperature from a outside temperature sensor
    -- * The Power consumption and energy consumption which is calculated in another Lua script 
    -- And uploads all of the values to a PVoutput account.
    -- For more information about PVoutput, see their user documentation on http://www.pvoutput.org/help.html
    --https://www.domoticz.com/wiki/Upload_energy_data_to_PVoutput
    -- Domoticz IDX of devices
    local GenerationDeviceName = "********" -- Device name of the Generated energy
    local TemperatureDeviceName = "********" -- Name of the temperature device that shows outside temperature
    -- PVoutput parameters
    local PVoutputApi = "********" -- Your PVoutput api key
    local PVoutputSystemID = "********" -- Your PVoutput System ID
    local PVoutputPostInterval = 5 -- The number of minutes between posts to PVoutput (normal is 5 but when in donation mode it's max 1)
    local PVoutputURL = '://pvoutput.org/service/r2/addstatus.jsp?key=' -- The URL to the PVoutput Service
    -- Require parameters
    local http = require("socket.http")
    -- Script parameters
    EnergyGeneration = 0 -- v1 in Watt hours
    PowerGeneration = 0 -- v2 in Watts
    CurrentTemp = 0 -- v5 in celcius
    c1 = 0 -- c1 = 0 when v1 is today's energy. c1 = 1 when v1 is lifetime energy.
    Debug = "NO" -- Turn debugging on ("YES") or off ("NO")
    -- Lua Functions
    function UploadToPVoutput(self)
    b, c, h = http.request("http" .. PVoutputURL .. PVoutputApi .. "&sid=".. PVoutputSystemID .. "&d=" .. os.date("%Y%m%d") .. "&t=" .. os.date("%H:%M") .. 
    "&v1=" .. EnergyGeneration .. "&v2=" .. PowerGeneration .. "&v5=" .. CurrentTemp ..  "&c1=" .. c1 ) if b=="OK 200: Added Status" then     print(" -- Current status successfully uploaded to PVoutput.") else     print(" -- " ..b) end print(" -- Energy generation (v1) = ".. EnergyGeneration .. " Wh") print(" -- Power generation (v2) = " .. PowerGeneration .. " W") print(" -- Current temperature (v5) = " .. CurrentTemp .. " C") print(" -- Cumulative Flag (c1) = " .. c1 .. "")
    end
    function update(device, id, power, energy, index)
    commandArray[index] = {['UpdateDevice'] = id .. "|0|" .. power .. ";" .. energy}
    end 
    -- CommandArray
    commandArray = {}
    time = os.date("*t") if PVoutputPostInterval>1 then     TimeToGo = PVoutputPostInterval - (time.min % PVoutputPostInterval)     print('Time to go before upload to PVoutput: ' ..TimeToGo.. " minutes") end if((time.min % PVoutputPostInterval)==0)then     -- Generated     PowerGeneration, EnergyGeneration = otherdevices_svalues[GenerationDeviceName]:match("([^;]+);([^;]+)")     if Debug=="YES" then         print(" ---- The total generated energy is " .. EnergyGeneration .. " Wh");         print(" ---- The current generated power is " .. PowerGeneration .. " W");     end     -- Temperature     CurrentTemp = otherdevices_svalues[TemperatureDeviceName]:match("([^;]+)")     if Debug=="YES" then         print(" ---- The outside temperature is " .. CurrentTemp .. " C.");     end     -- Upload data to PVoutput       UploadToPVoutput() end
    return commandArray