
-- verarbeitet das haupt slash event
function LmMinion.Slash.handleMainSlashCommand(command)
    
    -- fertig farbe einstellen
    if command:match("^color") or command:match("^farbe") then
        
        dump("farbe")
    else

        dump("hilfe")
    end

end