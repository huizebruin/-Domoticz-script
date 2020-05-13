-- ~/domoticz/scripts/lua/script_device_livingroomoff.lua
-- This script reads the current lumen-values from a lux sensor and
-- turns off the lights if the values is above a given number.
commandArray = {}

-- SETTINGS --
a = 'Lux Sensor-woonkamer' -- name of the lux sensor
b = '💡Woonkamer-Achter' -- name of a lamp that this script should depend on
c = '💡Woonkamer-Voor' -- name of an eventual second lamp that this script should depend on

d = 200 -- maximum lumen value

e = 'Scene:Huiskamer verlichting OFF' -- name of scenario to be initiated

p = 'Lights in the livingroom has been turned off due to high lumen-values' -- text to be printed in log
-- END SETTINGS --

-- Get values from the Lux sensor
V = otherdevices_svalues[a]

-- Function to strip charachters
function
 stripchars(str, chrs)
 local s = str:gsub("["..chrs.."]", '')
 return s
end

-- Strip " Lux" from V
w = stripchars( V, " Lux" )

-- Turn off lights if dimmer is on and Lux is higher than 200 (d)
if     (tonumber(w) > d and otherdevices[b] == 'On' or tonumber(w) > d and otherdevices[c] == 'On') then   
 commandArray[e]='Off'
 print(p)
end
return commandArray