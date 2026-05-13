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
        wait 0.05;

        players = getAllPlayers();
		for (i = 0; i < players.size; i++)
			players[i] hide();
        for (i = 0; i < players.size; i++)
        {
            current = players[i];

            for (j = 0; j < players.size; j++)
            {
                player = players[j];
                if (current == player)
                    continue;

                if (current.settings["player_hide"] == 0 || !current sameTeam(player))
                    player showToPlayer(current);
                if (current.settings["player_hide"] == 1 && distance(current.origin, player.origin) > 100)
					player showToPlayer(current);
            }
        }
    }
}
