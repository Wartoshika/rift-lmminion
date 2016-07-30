-- globale adventure variablen
local currentTimeAdventure = nil

-- holt sich den loot eines abenteuers
function LmMinion.Adventure.claimLoot(adventure)

    -- loot holen
    pcall(Command.Minion.Claim, adventure)
end

-- holt die blockierenden slots 
function LmMinion.Adventure.getMinionSlots()

    -- alle abenteuer holen
    local adventures = Inspect.Minion.Adventure.List()
    local minionSlot = {}

    -- nun alle durchgehen
    for adventure, v in pairs(adventures) do

        local adventureDetails = Inspect.Minion.Adventure.Detail(adventure)

        -- wenn ein scherge ab arbeiten ist
        if adventureDetails.minion then

            -- hochzaehlen egal ob fertig oder nicht weil ein platz blockiert ist
           table.insert(minionSlot, adventureDetails)
        end
    end

    -- abenteuer zurückgeben
    return minionSlot

end

-- gibt die anzahl freier slots zurück
function LmMinion.Adventure.getFreeSlotCount()

    -- blockierende slots holen
    local minionSlots = LmMinion.Adventure.getMinionSlots()

    -- ergebnis liefern
    return Inspect.Minion.Slot() - LmUtils.tableLength(minionSlots)
end

-- gibt die fertigen abenteuer zurueck
function LmMinion.Adventure.getFinishedAdventures()

    -- alle abenteuer holen
    local minionSlots = LmMinion.Adventure.getMinionSlots()
    local finished = {}
    local done = {}

    -- durchgehen, nur mode=finished sind relevant
    for index, adventure in pairs(minionSlots) do

        -- nur wenn ein abenteuer ein fertigstellungszeitpunkt hat
        if adventure.completion == nil then 
        
            -- zeit setzen
            adventure.completion = 0
        end

        -- mode pruefen
        -- mode = finished reicht nicht aus da es einen bug gibt wenn ein scherge
        -- ein abenteuer abgeschlossen hat ohne sterne. also auch die zeit pruefen
        local finishTime = adventure.completion - Inspect.Time.Server() 

        -- nun pruefen
        if adventure.mode == "finished" or finishTime <= 0 then

            -- gefunden, stacken!
            table.insert(done, adventure)
        end
    end

    -- anzahl zurueckgeben
    return done
end

-- gibt die anzahl fertiger abenteuer zurueck
function LmMinion.Adventure.getFinishedAdventureCount()

    return LmUtils.tableLength(LmMinion.Adventure.getFinishedAdventures())
end

-- gibt eine info fuer den benutzer im chat aus
function LmMinion.Adventure.printDetails(adventure)

    -- abenteuer
    local adventureDetails = Inspect.Minion.Adventure.Detail(adventure)

    -- schergenkarte holen
    local minion = Inspect.Minion.Minion.Detail(adventureDetails.minion)

    -- wenn sonder abentuer dann ist reward nil ...
    local adventureReward = "*"
    if adventureDetails.reward ~= nil then

        -- abenteuer reward nehmen
        adventureReward = adventureDetails.reward
    end

    -- ausgeben
    print("<" .. adventureReward .. "> " .. minion.name .. ":" .. minion.level .. " (" .. LmMinion.Adventure.getReadableDuration(adventureDetails.duration) .. ")")
end

-- gibt eine lesbare zeit aus
function LmMinion.Adventure.getReadableDuration(duration)

    -- berechnet einen teil
    local function getTimePart(partInSeconds, getUnit)

        -- einheit mit?
        if getUnit == nil then

            getUnit = true
        end

        -- ab sekunden rechnen
        local time = partInSeconds
        local unit = " Sek."

        -- groesser als 60?
        if time >= 60 and time < 60 * 60 then

            -- ja, minuten!
            time = time / 60
            unit = " Min."
        elseif time >= 60 * 60 then

            -- ja, stunden!
            time = time / 60 / 60
            unit = " Std."
        end

        -- runden!
        time = LmUtils.round(time)

        -- wenn negati dann 0 liefern
        if time < 0 then time = 0 end

        if getUnit then
            return  time .. unit
        else
            return time
        end 
    end

    if type(duration) ~= "table" then

        -- nur die sekunden berechnen
        return getTimePart(duration)
    else

        -- minimal und maximal berechnen
        local min, max = getTimePart(duration.min), getTimePart(duration.max) 

        -- wenn gleich dann nur eine zeit zurueckgeben
        if min == max then

            -- ein wert zurueckgeben
            return min;
        else

            -- min und max concaternieren
            -- @todo: wenn und max unterschiedliche einheiten haben dann stimmt dies nicht mehr
            --        aktuell gibt es aber keinen anwendungsfall 
            return getTimePart(duration.min, false) .. "-" .. max
        end
    end

end

-- gibt die stats eines abenteuers oder eines schergen zurueck
function LmMinion.Adventure.getAdventureOrMinitonStats(obj)

    -- alle stats stapeln
    local statStack = {}

    -- attribute durchgehen
    for key, val in pairs(obj) do

      -- wenn index mit stat anfaengt dann ist das ein treffer!
      if string.match(key, "stat") then

        -- ja!
        statStack[key] = val
      end
    end

    -- stapel zurueckgeben
    return statStack
end

-- prueft ob das abenteuer zu den zeitlichen einstellungen passt
function LmMinion.Adventure.fitDuration(adventureDurationSeconds)

    -- zeit holen
    local time = LmMinion.Options.minionAdventureLength

    -- min und max sind relevant
    return adventureDurationSeconds >= time.min and adventureDurationSeconds <= time.max 
    
end

-- liefert ein passendes abenteuer zurueck
function LmMinion.Adventure.getAdventure(checkCost)

    -- default fuer checkCost
    if checkCost == nil then checkCost = true end

    -- alle holen
    local adventures = Inspect.Minion.Adventure.List()
    local startAdventure = nil

    -- alle abenteuer durchgehen und ein neues finden
    for adventure, v in pairs(adventures) do

        -- details holen
        local adventureDetails = Inspect.Minion.Adventure.Detail(adventure)

        -- wenn verfuegbar
        if adventureDetails.mode == "available" and LmMinion.Adventure.fitDuration(adventureDetails.duration) then

            -- da aktuell die rift api einen bug hat sodass abenteuer keine kosten haben
            -- muss angenommen werden, dass die karte etwas kostet und versucht werden diese
            -- ohne kosten zu verschieben. wenn dann eine neue karte kommt, ist die vorherige eine
            -- kostenpflichtige gewesen
            if checkCost then

                -- shuffle
                pcall(Command.Minion.Shuffle, adventureDetails.id, "none")

                -- aufgabe holen
                local newAdventure = LmMinion.Adventure.getAdventure(false)

                -- andere abenteuer?
                if newAdventure.id ~= adventureDetails.id then

                    -- ja neues abenteuer, nochmal pruefen da evtl. die naechste
                    -- karte ebenfalls etwas kostet.
                    return LmMinion.Adventure.getAdventure()
                end
            end

            -- dieses nehmen!
            startAdventure = adventureDetails

            -- nicht mehr weiter nach abenteuer suchen
            break
        end
    end

    -- zurueckgeben
    return startAdventure
end

function LmMinion.Adventure.updateAdventureTime()

    -- laufende abenteuer
    local workingAdventures = {}

    -- erstmal zuruecksetzen
    currentTimeAdventure = nil

    -- abenteuer durchgehen und working ones speichern
    for adventure,v in pairs(Inspect.Minion.Adventure.List()) do

        -- details holen
        local adventureDetails = Inspect.Minion.Adventure.Detail(adventure);

        -- nur prufen wenn ueberhaupt laufen kann
        if adventureDetails.completion == nil then goto continue end

        -- zeit pruefen wg. 0 sterne schergen
        local timeCheck = adventureDetails.completion - Inspect.Time.Server()        

        -- pruefen ob mode=working ist
        if adventureDetails.mode == "working" and adventureDetails.completion and timeCheck > 0 then

            -- ja, stackend
            table.insert(workingAdventures, adventureDetails)
        end

        ::continue::
    end

    -- alle durchgehen und gucken wo completion am kleinsten ist
    for k, adventureDetails in pairs(workingAdventures) do

        -- pruefen
        if currentTimeAdventure == nil or adventureDetails.completion < currentTimeAdventure.completion then

            -- ja ist kleiner also aendern
            currentTimeAdventure = adventureDetails
        end

    end

    return currentTimeAdventure

end

-- gibt eine lesbare zeit vom abenteuer zurück welchen als nächstes endet
function LmMinion.Adventure.getSmallestTime()

    -- wenn currentTimeAdventure nil ist dann gibt es keine abenteuer
    if currentTimeAdventure == nil then

        -- nix ausgehen
        return "..."
    end

    -- so nun das ganze in zeit umrechnen
    local seconds = currentTimeAdventure.completion - Inspect.Time.Server()

    -- und ein to string cast
    return LmMinion.Adventure.getReadableDuration(seconds)

end