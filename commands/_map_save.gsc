#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

#include sr\sys\_common;

init()
{
	cmd("owner", "map_save", ::cmd_MapSave);

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
