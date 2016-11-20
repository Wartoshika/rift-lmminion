local addon = ...

-- initialisiert das addon
local function init()

    -- event wenn ein abenteuer fertig ist
    table.insert(Event.Minion.Adventure.Change, {
        LmMinion.Engine.adventureUpdateEvent,
        addon.identifier,
        "LmMinion.Engine.adventureUpdateEvent"
    })

    -- variablen laden
    if LmMinionGlobal then

        -- variablen laden wenn definiert
        for k,v in pairs(LmMinionGlobal) do

            -- einzelnd updaten
            -- event laenge nicht mit laden
            if not(k == "minionAdventureLength") then

                -- laden
                LmMinion.Options[k] = v;
            end

        end
        --LmMinion.Options = LmMinionGlobal
    end

    -- eventuelle migration durchfuehren
    LmMinion.VersionMigrationAdapter.migrate()

    -- gui bauen
    LmMinion.Ui.init(addon)

    -- gui aktuallisieren event
    LmMinion.Ui.update()
    Command.Event.Attach(Event.System.Update.End, LmMinion.Ui.updateTime, "LmMinion.Ui.updateTime")

    -- slash events registrieren
    table.insert(Command.Slash.Register("lmm"), {LmMinion.Slash.handleMainSlashCommand, addon.identifier, "LmMinion.Slash.handleMainSlashCommand"})

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

-- speichert die gesetzten optionen
local function saveOptionVariables()

    -- ueberschreiben
    LmMinionGlobal = LmMinion.Options

end

-- wenn addon geladen dann init durchfuehren
Command.Event.Attach(Event.Addon.Load.End, waitForRiftMinionSystem, "waitForRiftMinionSystem")
Command.Event.Attach(Event.Addon.Shutdown.Begin, saveOptionVariables, "saveOptionVariables")