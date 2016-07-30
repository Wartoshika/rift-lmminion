-- prueft ob der scherge in einem abenteuer ist
function LmMinion.Minion.checkInAdventure(minion)

    local adventures = Inspect.Minion.Adventure.List()

    -- wiedermal alle abenteuer durchgenen
    for adventure, k in pairs(adventures) do

        -- details holen
        local adventureDetails = Inspect.Minion.Adventure.Detail(adventure)

        -- wenn dieses abenteuer einen schergen hat, id pruefen
        if adventureDetails.minion == minion then

            -- ja gefunden!
            return true
        end

    end

    -- ist in keinem aktiven abenteuer
    return false;

end

-- sucht den schergen mit MIN stats raus
function LmMinion.Minion.getMinionWithMinStat(possibleStartMinions)

    local startMinion = nil

    -- nun sind alle moeglichen schergen gestackt die genug ausdauer haben und
    -- bei denen mindestens ein attribut passt. nur noch das niedrigste level herrausfinden
    for _, possibleMinion in pairs(possibleStartMinions) do

        if startMinion == nil or startMinion.level > possibleMinion.level then

            -- ersetzen!
            startMinion = possibleMinion
        end

    end

    -- zurueckgeben
    return startMinion
end

-- sucht den schergen mit MAX stats raus
function LmMinion.Minion.getMinionWithMaxStat(possibleStartMinions, adventureStats)

    local startMinion = nil
    local startMinionStatCounter = 0

    -- nun einen schergen suchen der die besten stats hat.
    -- das level spielt dabei keine rolle
    for k, minion in pairs(possibleStartMinions) do

        -- stat zaehler
        local statCounter = 0

        -- stats des schergen suchen
        local minionStats = LmMinion.Adventure.getAdventureOrMinitonStats(minion)

        -- stats des abenteuers durchgehen
        for _, stat in pairs(adventureStats) do

            -- wenn der scherge ein stat hat welches zum abenteuer passt dann
            -- hochzaehlen
            if minionStats[stat] ~= nil then

                statCounter = statCounter + minionStats[stat]
            end
        end

        -- so, nun gucken ob dieser scherge besser ist
        if startMinion == nil or statCounter > startMinionStatCounter then

            -- scherge ist besser
            startMinion = minion
            startMinionStatCounter = statCounter
        end
    end

    -- schergen zurueckgeben
    return startMinion

end

-- sucht einen schergen fuer uebertragene abenteuer
function LmMinion.Minion.getMinionForAdventure(adventureDetails)

    -- stats des abenteuers setzen
    local startAdventureStats = LmUtils.getTableKeys(LmMinion.Adventure.getAdventureOrMinitonStats(adventureDetails))
    local possibleStartMinions = {}

    -- alle schergen holen
    local minions = Inspect.Minion.Minion.List()

    -- nun den schergen suchen der passt
    for minion, v in pairs(minions) do

        -- details holen um stats zu vergleichen
        local minionDetails = Inspect.Minion.Minion.Detail(minion)

        -- fuer das abenteuer muessen genug ausdauerpunkte vorhanden sein!
        if minionDetails.stamina >= adventureDetails.costStamina then

            -- scherge hat genug ausdauer. nun muss mindestend ein attribut passen
            local minionStat = LmUtils.getTableKeys(LmMinion.Adventure.getAdventureOrMinitonStats(minionDetails))

            -- alle stats durchgehen
            for _, stat in pairs(minionStat) do

                -- attribut vorhanden?
                if LmUtils.tableHasValue(startAdventureStats, stat) and not LmMinion.Minion.checkInAdventure(minion) then

                    -- ja, stacken
                    table.insert(possibleStartMinions, minionDetails)
                end
            end

        end

    end

    -- option holen welche stats gesucht werden soll
    if LmMinion.Options.minionAdventureLength.minionStat == "min" then

        -- min stats suchen
        return LmMinion.Minion.getMinionWithMinStat(possibleStartMinions)
    else

        -- mit max stats suchen
        return LmMinion.Minion.getMinionWithMaxStat(possibleStartMinions, startAdventureStats)
    end

end