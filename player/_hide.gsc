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
            current = players[i];
			current hide();

            for (j = 0; j < players.size; j++)
            {
                player = players[j];
                if (current == player)
                    continue;

                if (current.settings["player_hide"] == 0 || !player sameTeam(current))
                    player showToPlayer(current);
                if (current.settings["player_hide"] == 1 && distance(current.origin, player.origin) > 100)
					player showToPlayer(current);
            }
        }
    }
}
