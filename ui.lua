-- lokale variablen wg. sichtbarkeit hier deklarieren
local frame, tooltip, zeit, addon

-- initialisiert die gui
function LmMinion.Ui.init(_addon)

    -- addon werte zwischenspeichern
    addon = _addon;

    -- frame erstellen
    local context = UI.CreateContext("MinionContext")
    frame =  UI.CreateFrame("Text", "LmMinionPannel", context)
    tooltip =  UI.CreateFrame("Text", "LmMinionTooltip", frame)
    zeit = UI.CreateFrame("Text", "LmMinionTime", frame);

    -- default werte
    frame:SetBackgroundColor(0, 0, 0, .5)
    frame:SetFontColor(0, 1, 0)
    frame:SetFontSize(18)
    frame:SetVisible(true)
    frame:SetPoint("CENTER", UIParent, "TOPLEFT", LmMinion.Options.windowX, LmMinion.Options.windowY)

    -- tooltip zusammenbauen
    tooltip:SetVisible(false)
    tooltip:SetFontColor(1, 1, 1)
    tooltip:SetBackgroundColor(0, 0, 0, .7)
    tooltip:SetPoint("BOTTOMCENTER", frame, "BOTTOMCENTER", 0, 140)

    -- zeit zusammenbauen
    zeit:SetText("...")
    zeit:SetBackgroundColor(0, 0, 0, .5)
    zeit:SetWidth(frame:GetWidth())
    zeit:SetFontSize(9)
    zeit:SetPoint("TOPCENTER", frame, "TOPCENTER", 0, -zeit:GetHeight())
    

    -- event listener erstellen
    LmMinion.Ui.createEventListeners()
end

-- erstellt verschiedene event listener
function LmMinion.Ui.createEventListeners()

    local dragDrop = false

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
    function frame.Event:MiddleClick ()
        
        -- laenge anpassen
        LmMinion.Engine.toggleLength()
    end

    -- mouseover fuer tooltip
    function frame.Event:MouseIn()

        -- tooltip anzeigen
        tooltip:SetVisible(true)

        -- einmal die gui updaten
        LmMinion.Adventure.updateAdventureTime()
        LmMinion.Ui.update()
        LmMinion.Ui.updateTime()
    end
    function frame.Event:MouseOut()

        -- tooltip anzeigen
        tooltip:SetVisible(false)
    end

    -- drag and drop
    function frame.Event:RightDown()
        
        dragDrop = true
    end
    function frame.Event:RightUp()
        
        dragDrop = false
    end
    function frame.Event:MouseMove()

        -- nur wenn drag drop aktiv
        if not dragDrop then return end

        -- mausposition holen
        local maus = Inspect.Mouse()

        -- position setzen und speichern
        LmMinion.Options.windowX = maus.x
        LmMinion.Options.windowY = maus.y

        -- frame offset position setzen
        frame:SetPoint("CENTER", UIParent, "TOPLEFT", LmMinion.Options.windowX, LmMinion.Options.windowY)

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
    frame:SetText( (max - freeSlots) .. " / " .. max )
    tooltip:SetText(addon.name .. " (v " .. addon.toc.Version .. ")\n--------------------------------------\nAktuelle Zeiteinstellung: " .. timeSetting .. "\n--------------------------------------\nMausrad drehen = Schergen versenden\nLinksklick = Abenteuer looten\nRechtsklick = Fenster verschieben\nMausrad druecken = Zeit einstellen")

    -- zeit frame breite anpassen
    zeit:SetWidth(frame:GetWidth())
    zeit:SetText(LmMinion.Adventure.getSmallestTime())

    -- farbe einstellen
    -- ab 20% rot - unter 81% orange - ab 81% weiss
    local percent = (max - freeSlots) / max * 100
    if percent <= 20 then
        frame:SetFontColor(1, 0, 0)
    elseif percent < 100 then
        frame:SetFontColor(1, .5, 0)
    else
        frame:SetFontColor(1, 1, 1)
    end

    -- mindestens ein abenteuer fertig? dann hintergrundfarbe anpassen
    if finished > 0 then

        -- hintergrund gruen faerben
        frame:SetBackgroundColor(.1, .75, .1);

        -- schrift muss dann zur besseren lesbarkeit weiss
        frame:SetFontColor(0, 0, 0)
    else

        -- hintergrund wieder normalisieren
         frame:SetBackgroundColor(0, 0, 0, .5);
    end

end

function LmMinion.Ui.updateTime()

    -- zeit frame breite anpassen
    zeit:SetWidth(frame:GetWidth())
    zeit:SetText(LmMinion.Adventure.getSmallestTime())

end