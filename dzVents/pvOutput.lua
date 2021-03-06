--[[
        dzVents version of pvOutput script.
pvOutput.lua downloaded van https://www.huizebruin.nl/domoticz/pvoutput-systeem-koppelen-aan-domoticz-v2020-1/
Bron : https://domoticz.com/forum/viewtopic.php?f=61&t=4714&start=100

Om een functie aan of uit te zetten haal of plaats de 2 streepjes voor de regel weg.

        api-key and id stored in domoticz uservariables:

            PVoutput_API     
            PVoutput_ID 

        both as type string

        v1 - energy generated
        v2 - power generated            W from 
        v3 - energy consumption
        v4 - power consumption
        v5 - temperature
        v6 - voltage

        c1 - Cumulatieve vlag 1 Zowel v1- als v3-waarden zijn levenslange energiewaarden.
Het verbruik en de opgewekte energie worden aan het begin van de dag op 0 gezet. 
2 Alleen v1 gegenereerd is een levenslange energiewaarde. 
3 Alleen v3-verbruik is een levenslange energiewaarde.

        
        n  - Net flag          Indien ingesteld op 1, geeft dit aan dat de vermogenswaarden netto export / import zijn.
                                in plaats van bruto gegenereerd / verbruik. 
            Deze optie wordt gebruikt voor apparaten die dat wel zijn niet in staat om bruto consumptiegegevens te rapporteren. 
            De verstrekte import- / exportgegevens worden samengevoegd met bestaande gegenereerde gegevens om het verbruik af te leiden.

        Donation mode only parms
        ========================
        '&delay=' .. Delay
        '&v7=' .. WaterConsumption
        '&v8=' .. InverterFrequency
        '&v11=' .. InverterTemp
        '&v12=' .. GasConsumption

]]

local scriptVar = 'PVOutput'

return 
{
    on =    
    { 
        timer = 
        { 
            'every 10 minutes', --om de 10 minuten is voor mij voldoende
        },
        httpResponses = 
        { 
            scriptVar,
        },
    },
 
    logging =    
    {   
        level = domoticz.LOG_DEBUG, -- change to LOG_ERROR when OK - was LOG_DEBUG
        marker = scriptVar,
    },

    execute = function(dz, item)

        local function post2PVOutput(PVSettings, postData)
            dz.openURL({
                url = PVSettings.url,
                method = 'POST',
                headers = {
                    ['X-Pvoutput-Apikey'] = PVSettings.api,
                    ['X-Pvoutput-SystemId'] = PVSettings.id
                },
                callback = scriptVar,
                postData = postData
            })
        end

        local function makepostData()
  --    local P1 = dz.devices('P1 Power')                   -- P1-Slimme meter (' **wijzigen** ')
        local generated = dz.devices('Solar Power')           -- Uitvoer van S0 meter omvormer (' **wijzigen** ')
  --    local consumed = dz.devices('Consumption')          -- Verbruik virtueel apparaat (' **wijzigen** ')
        local temperature = dz.devices('temp buiten voor')       -- Temperatuur sensor (' **wijzigen** ')
  --    local voltageDevice = dz.devices('uac1')            --  Voltage meting van (' **wijzigen** ')

            local round = dz.utils.round

       --     local voltageString = voltageDevice.sValue
       --    local voltage = round(tonumber(voltageString:match('%d*%.*%d*')),1) -- To prevent error if 'V' is part of the string
                        
      --      dz.log('P1         : ' .. P1.sValue,dz.LOG_DEBUG)
            dz.log('generated  : ' .. generated.nValue .. ';' .. generated.sValue,dz.LOG_DEBUG)
      --      dz.log('consumed   : ' .. consumed.nValue .. ';' .. consumed.sValue,dz.LOG_DEBUG)
            dz.log('Temperature: ' .. temperature.temperature,dz.LOG_DEBUG)
       --     dz.log('voltage    : ' .. voltage,dz.LOG_DEBUG)
            
            local postdDataAsString = 
                    'd=' .. os.date("%Y%m%d") ..
                    '&t=' .. os.date("%H:%M") .. 
                    
                    -- Gebruik deze als u netto productie van zonnepanelen wilt
                    '&v1=' .. round(generated.WhTotal,1) ..  -- produced
                    '&v2=' .. round(generated.actualWatt,1) ..
                    
                    -- Gebruik deze als u wilt dat je de gegevens van je slimme meter wilt gebruiken voor teruggave
                    -- '&v1=' .. P1.return1 + P1.return2 ..  -- returned to the grid
                    -- '&v2=' .. P1.usageDelivered ..
                    
                    -- Gebruik deze als u wilt dat je de gegevens van je slimme meter wilt gebruiken voor gebruik
                    -- '&v3=' .. P1.usage1 + P1.usage2 .. -- net values from your smart meter
                    -- '&v4=' .. P1.usage ..
                    
                    -- Gebruik deze als je wilt wat er wordt berekend
                   -- '&v3=' .. round(consumed.WhTotal,1) .. -- consumed 
                   -- '&v4=' .. round(consumed.actualWatt,1) ..
                       
                   -- Gebruik deze als je temperatuur en je voltage wilt uploaden
                    '&v5=' .. round(temperature.temperature,1) .. 
                   -- '&v6=' .. voltage ..

                    '&c1=1'

            return postdDataAsString
        end

        --hieronder hoef je niets te wijzigen

        if item.isHTTPResponse then
            dz.log("Return from PVOutput ==>> " .. item.data,dz.LOG_FORCE)
        else
            PVSettings = 
            {
            url = 'HTTPS://pvoutput.org/service/r2/addstatus.jsp',
            api = dz.variables('PVoutput_API').value,
            id  = dz.variables('PVoutput_ID').value,
            }
            post2PVOutput(PVSettings, makepostData())
        end
    end
}