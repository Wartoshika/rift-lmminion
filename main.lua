local addon = ...

-- initialisiert das addon
local function init()

    -- event wenn ein abenteuer fertig ist
    table.insert(Event.Minion.Adventure.Change, {
        LmMinion.Engine.adventureUpdateEvent,
        addon.identifier,
        "LmMinion.Engine.adventureUpdateEvent"
    })

    -- gui bauen
    LmMinion.Ui.init()

    -- einmal die gui aktuallisieren
    LmMinion.Ui.update()

    -- ausgabe wg. geladen
    print ("erfolgreich geladen (v " .. addon.toc.Version ..")")

end


-- wartet bis das rift schergensystem geladen ist
local function waitForRiftMinionSystem()

    -- prueffunktion ob geladen oder nicht
    local function checkRiftMinitonSystem()

        -- geladen?
        if Inspect.Minion.Adventure.List() == nil then

            -- noch nicht geladen
            return
        end

         -- event wieder entfernen
        Command.Event.Detach(Event.System.Update.End, checkRiftMinitonSystem, "checkRiftMinitonSystem")

        -- schlussendlich ...
        init()
    end

    -- update event listener hinzufuegen und addon load listener entfernen
    Command.Event.Detach(Event.Addon.Load.End, waitForRiftMinionSystem, "waitForRiftMinionSystem")
    Command.Event.Attach(Event.System.Update.End, checkRiftMinitonSystem, "checkRiftMinitonSystem")

end

-- wenn addon geladen dann init durchfuehren
Command.Event.Attach(Event.Addon.Load.End, waitForRiftMinionSystem, "waitForRiftMinionSystem")