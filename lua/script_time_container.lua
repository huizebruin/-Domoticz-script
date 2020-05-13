-- Get System Time/Date

time = os.date("*t")

weekday = os.date("%A")

minutes = time.min + time.hour * 60

-- Set Lua Path

lua_path = "/home/pi/domoticz/scripts/lua/"

commandArray = {}

if (time.min % 1)==0 then dofile(lua_path.."script_time_upload_to_PVoutput.lua") end
if (time.min % 5)==0 then dofile(lua_path.."script_time_sunrisesunset.lua") end


return commandArray