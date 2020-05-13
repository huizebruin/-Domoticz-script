-- Get System Time/Date

time = os.date("*t")

weekday = os.date("%A")

minutes = time.min + time.hour * 60

-- Set Lua Path

lua_path = "/home/pi/domoticz/scripts/lua/"

commandArray = {}

if devicechanged['DWS_Voordeur'] then dofile(lua_path.."verlichting_hal.lua")

dofile(lua_path.."alarm_trigger.lua") end

if devicechanged['DWS_Meterkast'] then dofile(lua_path.."alarm_trigger.lua") end

if devicechanged['DWS_Achterdeur'] then dofile(lua_path.."alarm_trigger.lua") end


if (time.min % 1)==0 then dofile(lua_path.."script_device_livingroomon.lua") end
if (time.min % 1)==0 then dofile(lua_path.."script_device_livingroomoff.lua") end
return commandArray