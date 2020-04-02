-- This script will run every minute and can automatically send an 'Off' command to turn off any device after
-- it has been on for some specified time. Each device can be individually configured by putting json coded 
-- settings into the device's description field. The settings currently supported are:
-- - "auto_off_minutes" : <time in minutes>
-- - "auto_off_motion_device" : "<name of a motion detection device>"
-- If "auto_off_minutes" is not set, the device will never be turned off by this script. If 
-- "auto_off_minutes" is set and <time in minutes> is a valid number, the device will be turned off when it 
-- is found to be on plus the device's lastUpdate is at least <time in minutes> minutes old. This behavior 
-- can be further modified by specifying a valid device name after "auto_off_motion_device". When a motion 
-- device is specified and the device's lastUpdate is at least <time in minutes> old, the device will not 
-- be turned off until the motion device is off and it's lastUpdate is also <time in minutes> old. 
-- Specifying "auto_off_motion_device" without specifying "auto_off_minutes" does nothing.
--
-- Example 1: turn off the device after 2 minutes:
-- {
-- "auto_off_minutes": 2
-- }
--
-- Example 2: turn off the device when it has been on for 5 minutes and no motion has been detected for 
-- at least 5 minutes:
-- {
-- "auto_off_minutes": 5,
-- "auto_off_motion_device": "Overloop: Motion"
-- }
-- zie afzuiging douche

return {
	on = {

		-- timer triggers
		timer = {
			'every minute'
		}
	},

	execute = function(domoticz, triggeredItem, info)

		domoticz.devices().forEach(
	        function(device)
	            if device.state ~= 'Off' then
	                --domoticz.log( 'device is on ' .. device.name .. '.', domoticz.LOG_INFO)
    	            local description = device.description
    	            if description ~= nil and description ~= '' then
    	                --domoticz.log( 'description = ' .. description .. '.', domoticz.LOG_INFO)
    	                local ok, settings = pcall( domoticz.utils.fromJSON, description)
    	                if ok then
    	                    if settings ~= nil and settings.auto_off_minutes ~= nil and device.lastUpdate.minutesAgo >= settings.auto_off_minutes then
	                            if settings.auto_off_motion_device == nil then
            		                domoticz.log(device.name .. ' is switched off because it has been on for ' .. settings.auto_off_minutes .. ' minutes.', domoticz.LOG_INFO)
	                                device.switchOff()
	                            else
                                    local motion_device = domoticz.devices(settings.auto_off_motion_device)
                                    if motion_device.state == 'Off' and motion_device.lastUpdate.minutesAgo >= settings.auto_off_minutes then
                		                domoticz.log(device.name .. ' is switched off because no one was in the room for ' .. settings.auto_off_minutes .. ' minutes.', domoticz.LOG_INFO)
    	                                device.switchOff()
                                    end
	                            end
                            end 
                        else
                            domoticz.log( 'Device description for '.. device.name ..' is not in json format. Ignoring this device.', domoticz.LOG_ERROR)
                        end
                    end
                end
            end
        )
    end
}
