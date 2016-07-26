-- ein abenteuer looten
function LmMinion.Engine.loot()

    -- ein fertiges abenteuer suchen und es pluendern
    local adventures = LmMinion.Adventure.getFinishedAdventures()

    -- gibt es ueberhaupt ein abenteuer?
    if LmUtils.tableLength(adventures) > 0 then

        -- ein abenteuer gefunden, pluendern!
        return LmMinion.Adventure.claimLoot(adventures[1].id)
    end

    -- kein abenteuer gefunden
    return false
end

-- ein abenteuer versenden
function LmMinion.Engine.send()

    -- send ueberhaupt freie plaetze vorhanden?
    if LmMinion.Adventure.getFreeSlotCount() == 0 then return false end

    -- ein abenteuer holen
    local adventure = LmMinion.Adventure.getAdventure()

    -- fehlervorbeugung
    if adventure == nil then

        -- fehler ausgeben
        print("Es konnte kein passendes Abenteuer gefunden werden.")
        return
    end

    -- einen schergen holen
    local minion = LmMinion.Minion.getMinionForAdventure(adventure)

    -- scherge gefunden?
    if minion == nil then

        -- fehler ausgeben
        print("Es konnte kein passender Scherge gefunden werden.")
        return
    end

    -- ok, scherge wegschicken!
    pcall(Command.Minion.Send, minion.id, adventure.id, "none")
    
end

-- veraendert die event laenge
function LmMinion.Engine.toggleLength()


    if LmMinion.Options.minionAdventureLength == "1 Min" then

        LmMinion.Options.minionAdventureLength = "5-20 Min"
    else
        LmMinion.Options.minionAdventureLength = "1 Min"

    end

    -- ui update event rufen
    LmMinion.Ui.update()

    -- neue laenge zurueckgeben
    return LmMinion.Options.minionAdventureLength
end

-- wenn es das schergen update event gibt
function LmMinion.Engine.adventureUpdateEvent(event)

    -- pruefen ob loot event oder versendet event
    if LmUtils.tableLength(event) > 1 then
        
        -- info ausgeben, welcher scherge auf welches event geschickt wurde
        -- es sind auch neue abenteuer angebenen
        for adventure, v in pairs(event) do

            -- nur abenteuer ausgeben wenn scherge gesetzt
            local adventureDetails = Inspect.Minion.Adventure.Detail(adventure)

            -- nil pruefung wenn abenteuer warum auch immer nicht mehr verfuegbar
            if adventureDetails ~= nil and adventureDetails.minion then

                -- ausgeben!
                LmMinion.Adventure.printDetails(adventureDetails.id)
            end
        end

    end

    -- abenteuer zeit changes setzen
    LmMinion.Adventure.updateAdventureTime()

    -- gui updaten
    LmMinion.Ui.update()
end