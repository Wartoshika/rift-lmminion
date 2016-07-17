local function init(addon)

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


init(...)