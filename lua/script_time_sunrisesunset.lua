-- script_time_sunriseset.lua
-- This script will flip a virtual switch ('isdark_switch') when it is dark
-- the switch will be turned off again when the sun comes up

local isdark_switch = 'IsDonker'

commandArray = {}

time = os.date("*t")  --Get current time
minutes = time.min + time.hour * 60  --Convert time to minutes
-- time.hour >= 22

    if ((minutes > (timeofday['SunriseInMinutes']) and minutes < (timeofday['SunsetInMinutes'])) and otherdevices[isdark_switch] == 'On') then
       commandArray[isdark_switch]='Off'
    elseif ((minutes > (timeofday['SunsetInMinutes']) or minutes < (timeofday['SunriseInMinutes'])) and otherdevices[isdark_switch] == 'Off') then
       commandArray[isdark_switch]='On'       
    end
 return commandArray