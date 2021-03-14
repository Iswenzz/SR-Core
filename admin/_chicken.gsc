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
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

#include sr\sys\_gsxcommon;

init()
{
	map = getDvar("mapname");
	path = "./sr/server_data/speedrun/chicken/"+map+".txt";
	file_exists = checkfile(path);

	if(!file_exists)
		return;
	else
		thread spawn_chicken(path);
}

spawn_chicken(path)
{
	chicken = [];

	r = readAll(path);
	for(i=0; i<r.size; i++)
	{
		a = StrTok(r[i],"\\");
		if(isDefined(a[0]) && isDefined(a[1]) && isDefined(a[2]) && isDefined(a[3]))
		{
			chicken[a[0]] = spawn("script_model",(toFloat(a[1]),toFloat(a[2]),toFloat(a[3])));
			chicken[a[0]] setModel("chicken");
			chicken[a[0]].realModel = "chicken";
		}
	}
}
