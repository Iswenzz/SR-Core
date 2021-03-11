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
#include sr\sys\_gsxcommon;

init()
{
	self thread update_hud();
}

update_hud()
{
	self endon("disconnect");
	self endon("death");
	
	self.guid = getSubStr(self getGuid(), 24, 32);
	self.name_small = getSubStr(self.name, 0, 15);

	self setClientDvar("sr_anticheat_player_id",self.playerID);
	self setClientDvar("sr_anticheat_player_name",self.name_small);
	self setClientDvar("sr_anticheat_player_run",self.runNumber);
	self setClientDvar("sr_anticheat_player_guid",self.guid);
}

spec()
{
	self endon("disconnect");
	self endon("spawned_player");
	
	while(self.sessionstate != "playing")
	{
		player = self getspectatorClient();

		if(!isDefined(player))
		{
			wait 0.05;
			continue;
		}

		player.guid = getSubStr(player getGuid(), 24, 32);
		player.name_small = getSubStr(player.name, 0, 15);

		if(player.isBot)
		{
			player.guid = "^84201337";
			player.playerID = "0000000";
		}

		self setClientDvar("sr_anticheat_player_id",player.playerID);
		self setClientDvar("sr_anticheat_player_name",player.name_small);
		self setClientDvar("sr_anticheat_player_run",player.runNumber);
		self setClientDvar("sr_anticheat_player_guid",player.guid);
		
		wait 0.1;
	}
}
