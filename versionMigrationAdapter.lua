function LmMinion.VersionMigrationAdapter.migrate()

    -- migration von x zu 1.2
    if type(LmMinion.Options.minionAdventureLength) == "string" then

        -- es sollte table sein!
        LmMinion.Options.minionAdventureLength = LmMinion.PossibleAdventureLength[2]

        -- ausgabe durchfuehren
        print("Addon Update erfolgreich. Gespeicherte Daten uebernommen.")
    end
end