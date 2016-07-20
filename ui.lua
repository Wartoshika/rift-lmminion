local frame
local tooltip

-- initialisiert die gui
function LmMinion.Ui.init()

    -- frame erstellen
    local context = UI.CreateContext("MinionContext")
    frame =  UI.CreateFrame("Text", "LmMinionPannel", context)
    tooltip =  UI.CreateFrame("Text", "LmMinionTooltip", context)

    -- default werte
    frame:SetBackgroundColor(0, 0, 0, .5)
    frame:SetFontColor(0, 1, 0)
    frame:SetVisible(true)

    -- tooltip zusammenbauen
    tooltip:SetVisible(false)
    tooltip:SetFontColor(1, 1, 1)
    tooltip:SetBackgroundColor(0, 0, 0, .7)
    tooltip:SetPoint("TOP", frame, "BOTTOM")
    tooltip:SetText("Mausrad = Schergen versenden\nLinksklick = Abenteuer looten\nRechtsklick = Abenteuerdauer einstellen")

    -- event listener erstellen
    LmMinion.Ui.createEventListeners()
end

-- erstellt verschiedene event listener
function LmMinion.Ui.createEventListeners()

    -- mausrad events zum versenden und looten der schergen verwenden
    function frame.Event:WheelForward ()

        -- senden!
        LmMinion.Engine.send()
    end
    function frame.Event:WheelBack ()

        -- senden!
        LmMinion.Engine.send()
    end

    -- looten
    function frame.Event:LeftClick ()

        -- looten
        LmMinion.Engine.loot()
    end

    -- einstellungen
    function frame.Event:RightClick ()
        
        -- laenge anpassen
        LmMinion.Engine.toggleLength()
    end

    -- mouseover fuer tooltip
    function frame.Event:MouseIn()

        -- tooltip anzeigen
        tooltip:SetVisible(true)
    end
    function frame.Event:MouseOut()

        -- tooltip anzeigen
        tooltip:SetVisible(false)
    end
end

function LmMinion.Ui.update()

    -- anzahl freier slots fuer schergen
    -- anzahl max slots
    -- fertige abenteuer
    -- und die einstellung der zeit fuer das versenden
    local freeSlots = LmMinion.Adventure.getFreeSlotCount()
    local max = Inspect.Minion.Slot()
    local finished = LmMinion.Adventure.getFinishedAdventureCount()
    local timeSetting = LmMinion.Options.minionAdventureLength

    -- nun die gui erneuern
    frame:SetText( (max - freeSlots) .. " / " .. max .. "  F: " .. finished  .. "\n" .. timeSetting )

    -- farbe einstellen
    -- ab 20% rot - unter 81% orange - ab 81% gruen
    local percent = (max - freeSlots) / max * 100
    if percent <= 20 then
        frame:SetFontColor(1, 0, 0)
    else percent < 100 then
        frame:SetFontColor(1, .5, 0)
    else
        frame:SetFontColor(0, 1, 0)
    end

end