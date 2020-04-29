--[[ 
    dzVents script time.
	Download from huizebruin.nl

]] --
return {
            on =    { 
                        timer = { 'at 23:59'},
                    },
 
       logging =    {   
                        level   =   domoticz.LOG_DEBUG, -- set to error when all OK
                        marker  =   "Dag verbruik en opbrengst" 
                    },    

    execute = function(dz)

        local vandaagKwh = dz.devices('Elektriciteit').counterToday -- Stroommeter device
        local vandaagSolar = dz.devices('Solar Power').counterToday -- Solar device
        local subject = (dz.moduleLabel or 'Solar Power'):gsub('#','')

    dz.log("VandaagKwh",dz.LOG_DEBUG)
    dz.log(vandaagKwh,dz.LOG_DEBUG)
    dz.log("Kwh",dz.LOG_DEBUG)
    dz.log("VandaagSolar",dz.LOG_DEBUG)
    dz.log(vandaagSolar,dz.LOG_DEBUG)
    dz.log("Kwh",dz.LOG_DEBUG)
    
 dz.notify(subject, 'Opbrengst zonnepanelen ' ..vandaagSolar.. ' kWh', dz.PRIORITY_MEDIUM, dz.SOUND_PERSISTENT, nil, dz.NSS_TELEGRAM)
 dz.notify(subject, 'Verbruik vandaag ' ..vandaagKwh.. ' kWh', dz.PRIORITY_MEDIUM, dz.SOUND_PERSISTENT, nil, dz.NSS_TELEGRAM)


    end

}