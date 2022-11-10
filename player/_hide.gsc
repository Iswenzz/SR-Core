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
        for (i = 0; i < players.size; i++)
        {
            if (!isDefined(players[i].pers["team"]))
                continue;

            // Activator should be visible to everyone
            if (players[i].pers["team"] == "axis")
                players[i] show();
            else if (!players[i].hidden)
                players[i] hide();
        }
        for (i = 0; i < players.size; i++)
        {
            current = players[i];

            for (j = 0; j < players.size; j++)
            {
                player = players[j];

                if (current == player)
                    continue;

                if (!current.settings["player_hide"])
                    player showToPlayer(current);
                else if (current.settings["player_hide"] == 1)
                {
                    if (distance(current.origin, player.origin) > 100)
                        player showToPlayer(current);
                }
            }
        }
    }
}
