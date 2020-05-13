-- When entering room, script reads current light level
-- and turns on the lights in the room based on given options.
-- If it's between 8AM and 8PM it chooses a scenery for day-lights,
-- and otherwise for evening/night-lights. It also measures the
-- lumen-values and decides if it is to bright in the room to
-- turn on the lights.
commandArray = {}

-- SETTINGS --
a = 'Lux Sensor-woonkamer' -- name of the lux sensor
b = 'Motion Sensor' -- name of the motion sensor
c = '💡Woonkamer-Achter ' -- name of a lamp that this script should depend on

d = 200 -- maximum lumen value
p = 'Lights in the livingroom has been turned on due to high lumen-values' -- text to be printed in log

-- END SETTINGS --

-- Define hours for day and evening lights
h = tonumber((os.date('%H')))
if     (h >= 8 and h < 20)
   then
   x = 'Scene:Huiskamer verlichting ON day'
   else
   x = 'Scene:Huiskamer verlichting ON night'
end

-- Get values from Lux sensor
V = otherdevices_svalues[a]

-- Remove charachters from datastring
function stripchars(str, chrs)
   local s = str:gsub("["..chrs.."]", '')
   return s end

-- Remove " Lux" from V
w = stripchars( V, " Lux" )

-- Issue command "x" if lux is below 200 (d) and motion is detected and dimmer is off
if    (tonumber(w) <= d and otherdevices[c] == 'Off') then   
   commandArray[x]='On'
   print(x)
end
return commandArray