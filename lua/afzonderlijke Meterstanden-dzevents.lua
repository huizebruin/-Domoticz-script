--[[ 
     dzVents script dzVents script time
     om P1 Smart Meter Elektriciteitswaarde te ontleden in afzonderlijke Meterstanden.
     Houd er rekening mee dat de teller van vandaag aanvankelijk tot de volgende dag bij de GUI een verkeerde waarde zal weergeven.
     Script gedownload van huizebruin.nl
https://www.huizebruin.nl/domoticz/slimme-meter-(p1)-opsplitsen-naar-4-tellers-domoticz-met-lua/
     Te gebruiken voor domoticz versie >= V4.11305
]] --
local fetchIntervalMins = 20    -- (Geheel) Minutenfrequentie van deze scriptuitvoering 1 = elke minuut, 10 = elke 10 minuten, enz.) Moet een van (1,2,3,4,5,6,10,12,15,20,30) zijn.
local ScriptVersion = '1.0.8' -- domoticz > V2020.1 / dzVents >= 2.4.28
 
return {

    on =      {
                        timer = { 'every ' .. fetchIntervalMins .. ' minutes' }
              },
             
    logging = {
                         level = domoticz.LOG_DEBUG,    -- Maak commentaar op deze regel om de instelling van dzVents global logging te overschrijven
                         marker = 'Afzonderlijke Meterstanden '.. ScriptVersion
              },

    data = { lastP1 = { initial = {} }},

    execute = function(dz, item)

        -- Voeg apparaatnamen toe tussen aanhalingstekens of apparaat-idx zonder aanhalingstekens
        local P1  = dz.devices(1) -- Electra, P1 Smart Meter device (idx or "name") (required)

--[[ Voer namen / idx in voor apparaten die je wilt onder deze commentaarregels
     Deze apparaten moeten worden gemaakt als nieuwe incrementele tellers. Script kan verkeerde waarden opleveren
     bij gebruik met bestaande die al waarden bevatten
     De resterende regels kunnen worden verwijderd of becommentarieerd 
]]--
        local usageLow = dz.devices('Verbruik Laag') -- Metergebruik laag, virtueel apparaat, teller incrementeel
        local usageHigh = dz.devices('Verbruik Hoog') -- Metergebruik Hoog, Virtueel apparaat, teller incrementeel
        local returnLow  = dz.devices('Teruglevering Laag')  -- Meter Return Laag, Virtueel apparaat, teller incrementeel
        local returnHigh = dz.devices('Teruglevering Hoog')  -- Meter Return Hoog, Virtueel apparaat, teller incrementeel

        -- Onder deze regel zijn geen wijzigingen vereist ---
               lastP1 = dz.data.lastP1

        local function updateCounter(dv, value, previousValue )
            if not(dv) then return end
            if not(previousValue) then
                dz.log("Geen eerdere gegevens voor " .. dv.name .. " nog; deze run overslaan",dz.LOG_DEBUG)
                return
            end
            if dv.counter ~= 0 then
                value = value - previousValue
            end
            dv.updateCounter(value)
            dz.log("Increment " .. dv.name .. " with: " .. value,dz.LOG_DEBUG)
        end 

        -- Update the device
        updateCounter(usageLow, P1.usage1, lastP1.usage1)
        updateCounter(usageHigh, P1.usage2, lastP1.usage2)
        updateCounter(returnLow, P1.return1, lastP1.return1)
        updateCounter(returnHigh, P1.return2, lastP1.return2)

        lastP1.usage1 = P1.usage1
        lastP1.usage2 = P1.usage2
        lastP1.return1 = P1.return1
        lastP1.return2 = P1.return2
     end
}