--[[ Badkamer_afzuiging dzVents script time
     Script gedownload van huizebruin.nl
    Te gebruiken voor domoticz versie >= V4.11305
]]--
local myDevicename = 'Badkamer_afzuiging'
local myEvent = 'Badkamer'

return
{
    on =
    {
        devices =
        {
            myDevicename,           
        },
        customEvents =
        {
            myEvent,
        },
    },
   
    logging =
    {
        level = domoticz.LOG_DEBUG,  -- change to LOG_ERROR when ok
        marker = 'Badkamer_afzuiging',
    },

    execute = function(dz, item)
       
        local myDevice = dz.devices(myDevicename)
       
        local msgAan = 'De Badkamer_afzuiging is aangezet!'
        local msgKlaar = 'Het douchen is klaar om Badkamer_afzuiging na te laten draaien!'
        local msgWordt = 'De Badkamer_afzuiging staat nog aan en wordt nu uitgezet!'
        local msgUit = 'De Badkamer_afzuiging is uitgezet!'
      
        local klaarDelay = 30
        local OffDelay = 60 - klaarDelay
       
       
        local function osCommand(cmd, foreGround)
            local foreGround = foreGround and '' or ' &'
            local cmd = cmd .. foreGround
           
            dz.log('Executing Command: ' .. cmd,dz.LOG_DEBUG)
           
            local fileHandle = assert(io.popen(cmd .. ' 2>&1 || echo ::ERROR::', 'r'))
            local commandOutput = assert(fileHandle:read('*a'))
            local returnTable = {fileHandle:close()}

            if commandOutput:find '::ERROR::' then     -- something went wrong
                dz.log('Error ==>> ' .. tostring(commandOutput:match('^(.*)%s+::ERROR::') or ' ... but no error message ' ) ,dz.LOG_DEBUG)
            else -- all is fine!!
                dz.log('ReturnCode: ' .. returnTable[3] .. '\ncommandOutput:\n' .. commandOutput, dz.LOG_DEBUG)
            end

            return commandOutput,returnTable[3] -- rc[3] contains returnCode
        end
       
       
        local function sendMQTT(message, topic)
            local MQTTTopic = topic or 'domoticz/out'
            local json = {} json.msg = message
            json = dz.utils.toJSON(json)
        
            osCommand ( 'mosquitto_pub' ..  ' -t '  .. MQTTTopic .. " -m '" .. json .. "'")
        end
       
        local function sendMessage(message, emitMinutes)
           
            local subject = (dz.moduleLabel or 'Badkamer_afzuiging'):gsub('#','')
            dz.notify(subject, message, dz.PRIORITY_MEDIUM, dz.SOUND_PERSISTENT, nil, dz.NSS_TELEGRAM)

            sendMQTT(message)
           
            dz.log(message,dz.LOG_DEBUG)
            if emitMinutes ~= nil then dz.emitEvent(myEvent, emitMinutes).afterMin(emitMinutes) end
            -- if emitMinutes ~= nil then dz.emitEvent(myEvent, emitMinutes).afterSec(emitMinutes) end -- for test only
        end
       
        if item.isDevice and item.state == 'On' then
            sendMessage(msgAan, klaarDelay)
                       
        elseif item.isCustomEvent and myDevice.state == 'On' and tonumber(item.data) == klaarDelay then
            sendMessage(msgKlaar, OffDelay)
           
        elseif item.isCustomEvent and myDevice.state == 'On' and tonumber(item.data) == OffDelay then
            myDevice.switchOff().silent()
            sendMessage(msgWordt)
           
        elseif item.isDevice and item.state == 'Off' then
            sendMessage(msgUit)
           
        end
    end
}