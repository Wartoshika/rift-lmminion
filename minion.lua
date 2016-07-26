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

function LmMinion.Minion.getMinionForAdventure(adventureDetails)

    -- stats des abenteuers setzen
    local startAdventureStats = LmMinion.Adventure.getAdventureOrMinitonStats(adventureDetails)
    local startMinion = nil
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
            local minionStat = LmMinion.Adventure.getAdventureOrMinitonStats(minionDetails)

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

    -- nun sind alle moeglichen schergen gestackt die genug ausdauer haben und
    -- bei denen mindestens ein attribut passt. nur noch das niedrigste level herrausfinden
    for _, possibleMinion in pairs(possibleStartMinions) do

        if startMinion == nil or startMinion.level > possibleMinion.level then

            -- ersetzen!
            startMinion = possibleMinion
        end

    end

    -- passenden schergen zurueckgeben
    return startMinion
end