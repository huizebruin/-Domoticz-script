return {
      on = { 
        timer = {
           'every 15 minutes'            
        },
    }, 
    execute = function(domoticz, device, timer)

       
        local Zonnepanelen  = domoticz.devices('Zonnepanelen opbrengst')
        local vandaagKwh   = domoticz.devices('Solar Power').counterToday

        -- Eenheidsprijs in Euro's / Kwh - M3
        local kwhPrijs = 0.22875
         if (domoticz.time == 'Between 23:00 and 07:00') or (domoticz.day == 'Saturday') or (domoticz.day == 'Sunday') then
            kwhPrijs = 0.21330 -- Daltarief
        else
            kwhPrijs = 0.22875 -- Normaal tarief
        end 
       
        -- Vaste kosten in Euro's per dag (zoals vastrecht) 
        local kwhPrijsVast = 0.1435

        -- Kosten berekenen
        local kwhKosten = tonumber(domoticz.utils.round( (kwhPrijs * vandaagKwh) + kwhPrijsVast,2))   

        -- Kosten updaten
          Zonnepanelen.updateCustomSensor(kwhKosten)
    end
} 