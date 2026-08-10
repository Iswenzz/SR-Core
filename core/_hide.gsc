#include sr\sys\_events;
#include sr\utils\_common;

main()
{
    thread playersVisibility();
}

playersVisibility()
{
    level endon("game over");

    while (true)
    {
        wait 0.1;

        players = getAllPlayers();
        observers = getHidingObservers(players);

        for (i = 0; i < players.size; i++)
        {
            player = players[i];

            if (!player tagHiders(observers))
            {
                if (player.hidden)
                {
                    player show();
                    player.hidden = false;
                }
                continue;
            }
            player.hidden = true;
            player hide();

            for (j = 0; j < players.size; j++)
            {
                if (players[j] != player && !players[j].hidesTarget)
                    player showToPlayer(players[j]);
            }
        }
    }
}

getHidingObservers(players)
{
    observers = [];
    for (i = 0; i < players.size; i++)
    {
        players[i].hidesTarget = false;
        players[i].hidden = IfUndef(players[i].hidden, false);

        if (players[i] sr\core\_settings::getPlayerSetting("player_hide", 0))
            observers[observers.size] = players[i];
    }
    return observers;
}

tagHiders(observers)
{
    count = 0;
    for (i = 0; i < observers.size; i++)
    {
        observer = observers[i];
        observer.hidesTarget = false;

        if (observer == self || !observer sameTeam(self))
            continue;
        if (observer.settings["player_hide"] == 1 && distance(observer.origin, self.origin) > 100)
            continue;

        observer.hidesTarget = true;
        count++;
    }
    return count;
}
