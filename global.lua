LmMinion = {
    Engine = {},
    Adventure = {},
    Minion = {},
    Ui = {},
    Util = {},
    Slash = {},
    Options = {
        minionAdventureLength = {
            min = 300,
            max = 1200,
            cost = "none",
            minionStat = "min"
        },
        windowX = 100,
        windowY = 100,
        minionFinishedBackgroundColor = {
            r = .1,
            g = .75,
            b = .1
        }
    },
    PossibleAdventureLength = {
        {
            -- erfahrungsabenteuer
            min = 60,
            max = 60,
            cost = "none",
            minionStat = "min"
        }, {
            -- standard 5-20 min abenteuer
            min = 300,
            max = 1200,
            cost = "none",
            minionStat = "min"
        }, {
            -- premium abenteuer
            min = 14400,
            max = 14400,
            cost = "aventurine",
            minionStat = "max"
        }, {
            -- standard langes abenteuer
            min = 28800,
            max = 28800,
            cost = "none",
            minionStat = "max"
        }   
    }
}