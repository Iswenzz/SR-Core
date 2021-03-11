/*

  _|_|_|            _|      _|      _|                  _|            
_|        _|    _|    _|  _|        _|          _|_|    _|  _|_|_|_|  
  _|_|    _|    _|      _|          _|        _|    _|  _|      _|    
      _|  _|    _|    _|  _|        _|        _|    _|  _|    _|      
_|_|_|      _|_|_|  _|      _|      _|_|_|_|    _|_|    _|  _|_|_|_|  

Script made by SuX Lolz (Iswenzz) and Sheep Wizard

Steam: http://steamcommunity.com/profiles/76561198163403316/
Discord: https://discord.gg/76aHfGF
Youtube: https://www.youtube.com/channel/UC1vxOXBzEF7W4g7TRU0C1rw
Paypal: suxlolz@outlook.fr
Email Pro: suxlolz1528@gmail.com

*/
init(modVersion)
{
    thread HidePlayers();
}

HidePlayers()
{
    while (true)
    {
        players = braxi\_common::getAllPlayers();
        for (i = 0; i < players.size; i++) 
        {
            if (!isDefined(players[i].pers["team"]))
                continue;

            // Activator should be visible to everyone
            if (players[i].pers["team"] == "axis")
                players[i] show();
            else
                players[i] hide();
        }
        for (i = 0; i < players.size; i++) 
        {
            for (j = 0; j < players.size; j++) 
            {
                if ((!isDefined(players[j].ghost) || !players[j].ghost) 
                    && (isDefined(players[i].pers) && isDefined(players[i].pers["hideplayers"]) || players[i].pers["team"] == "axis"))
                {
                    if (!players[i].pers["hideplayers"])
                        players[j] showToPlayer(players[i]); 
                    // TODO HIDE NEAR PLAYERS
                    // else if (players[i].pers["hideplayers"] == 2 && distance2D(players[i].origin, players[j].origin) <= 3)
                    //     players[j] showToPlayer(players[i]);
                }
            }
        }
        wait 0.3;
    }
}
