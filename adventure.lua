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
    return Inspect.Minion.Slot() - LmMinion.Util.tableLength(minionSlots)
end

-- gibt die fertigen abenteuer zurueck
function LmMinion.Adventure.getFinishedAdventures()

    -- alle abenteuer holen
    local minionSlots = LmMinion.Adventure.getMinionSlots()
    local finished = {}
    local done = {}

    -- durchgehen, nur mode=finished sind relevant
    for index, adventure in pairs(minionSlots) do

        -- mode pruefen
        if adventure.mode == "finished" then

            -- gefunden, stacken!
            table.insert(done, adventure)
        end
    end

    -- anzahl zurueckgeben
    return done
end

-- gibt die anzahl fertiger abenteuer zurueck
function LmMinion.Adventure.getFinishedAdventureCount()

    return LmMinion.Util.tableLength(LmMinion.Adventure.getFinishedAdventures())
end

-- gibt eine info fuer den benutzer im chat aus
function LmMinion.Adventure.printDetails(adventure)

    -- abenteuer
    local adventureDetails = Inspect.Minion.Adventure.Detail(adventure)

    -- schergenkarte holen
    local minion = Inspect.Minion.Minion.Detail(adventureDetails.minion)

    -- ausgeben
    print("<" .. adventureDetails.reward .. "> " .. minion.name .. ":" .. minion.level .. " (" .. LmMinion.Adventure.getReadableDuration(adventureDetails.duration) .. ")")
end

-- gibt eine lesbare zeit aus
function LmMinion.Adventure.getReadableDuration(durationInSeconds)

  -- ab minuten rechnen
  local time = durationInSeconds / 60
  local unit = " Min"

  -- groesser als 60?
  if time >= 60 then

    -- ja, stunden!
    time = time / 60
    unit = " Std"
  end

  return time .. unit
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
        table.insert(statStack, key)
      end
    end

    -- stapel zurueckgeben
    return statStack
end

-- prueft ob das abenteuer zu den zeitlichen einstellungen passt
function LmMinion.Adventure.fitDuration(adventureDurationSeconds)

        -- details holen
        if LmMinion.Options.minionAdventureLength == "1 Min" then

            -- eine minute in sekunden
            return adventureDurationSeconds == 60
        elseif LmMinion.Options.minionAdventureLength == "5-20 Min" then

            -- 5 bis 15 min in sekunden!
            return adventureDurationSeconds >= 300 and adventureDurationSeconds <= 1200
        end

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