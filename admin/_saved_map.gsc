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
	path = "./sr/server_data/speedrun/saved_map/"+map+".txt";
	file_exists = checkfile(path);

	if(!file_exists)
		return;
	else
		thread spawn_brushes(path);
}

spawn_brushes(path)
{
	brushes = [];

	r = readAll(path);
	for(i=0; i<r.size; i++)
	{
		a = StrTok(r[i],"\\");
		if(isDefined(a[0]) && isDefined(a[1]) && isDefined(a[2]) && isDefined(a[3]) && isDefined(a[4]) && isDefined(a[5]) && isDefined(a[6]) && isDefined(a[7]) && isDefined(a[8]))
		{
			if(isDefined(getEntArray(a[7],"targetname")) && getEntArray(a[7],"targetname").size == 1)
			{
				brushes[a[0]] = getEntArray(a[7],"targetname");
				brushes[a[0]][0] moveTo((toFloat(a[1]),toFloat(a[2]),toFloat(a[3])),0.05);
				brushes[a[0]][0].angles = (toFloat(a[4]),toFloat(a[5]),toFloat(a[6]));
			}

			if(isDefined(getEntArray(a[7],"targetname")) && getEntArray(a[7],"targetname").size > 1)
			{
				brushes[a[0]] = getEntArray(a[7],"targetname");
				brushes[a[0]][int(a[8])] moveTo((toFloat(a[1]),toFloat(a[2]),toFloat(a[3])),0.05);
				brushes[a[0]][int(a[8])].angles = (toFloat(a[4]),toFloat(a[5]),toFloat(a[6]));
			}
		}
		wait 0.05;
	}
}
