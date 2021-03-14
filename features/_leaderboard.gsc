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
#include braxi\_common;
#include braxi\_dvar;
#include sr\sys\_gsxcommon;

displayTop10(a)
{
    number = "";
    names = "";
    times = "";
    split = "";

    self setClientDvar("top10_leaderboard_number", "");
    self setClientDvar("top10_leaderboard_names", "");
    self setClientDvar("top10_leaderboard_times", "");
    self setClientDvar("top20_leaderboard_number", "");
    self setClientDvar("top20_leaderboard_names", "");
    self setClientDvar("top20_leaderboard_times", "");
    self setClientDvar("top30_leaderboard_number", "");
    self setClientDvar("top30_leaderboard_names", "");
    self setClientDvar("top30_leaderboard_times", "");

    if(!isDefined(a))
    	return;

    if(!isDefined(a.size))
    	return;

    l = a.size;

    if(l > 10)
        l = 10;
 
    for(i = 0; i < l; i++)
    {
        n = i; n++;
        number += "#" + n + "\n";
        colour = "^7";

        for(z = 0; z < level.vipList.size; z++)
        {
            if(a[i]["guid"] == level.vipList[z])
            {
                colour = "^2";
                break;
            }
        }

        if(n == 1)
            colour = "^3";
        if(n == 2)
            colour = "^8";
        if(n == 3)
            colour = "^9";
        if(a[i]["name"].size > 16 )
            names += colour+GetSubStr(a[i]["name"], 0, 15)+"\n";
        else
            names += colour+a[i]["name"] + "\n";
        times += a[i]["time"].min + ":" + a[i]["time"].sec + "." + a[i]["time"].milsec + "\n";

        if(i == 0)
        {
            split += "\n";
            continue;
        }

        x = realtime(a[i]["time"].ori - a[i-1]["time"].ori);
        split += "^1-" + x.min + ":" + x.sec + "." + x.milsec + "\n";
    }

    self setClientDvar("top10_leaderboard_number", number);
    self setClientDvar("top10_leaderboard_names", names);
    self setClientDvar("top10_leaderboard_times", times);
 
    number = "";
    names = "";
    times = "";
    split = "";

    if(!isDefined(a))
    	return;

    if(!isDefined(a.size))
    	return;

    l = a.size;

    if(l > 20)
        l = 20;
 
    for(i = 10; i < l; i++)
    {
        n = i; n++;
        number += "#" + n + "\n";
        colour = "^7";

        for(z = 0; z < level.vipList.size; z++)
        {
            if(a[i]["guid"] == level.vipList[z])
            {
                colour = "^2";
                break;
            }
        }

        if(a[i]["name"].size > 16 )
            names += colour+GetSubStr(a[i]["name"], 0, 15)+"\n";
        else
            names += colour+a[i]["name"] + "\n";
        times += a[i]["time"].min + ":" + a[i]["time"].sec + "." + a[i]["time"].milsec + "\n";

        if(i == 0)
        {
            split += "\n";
            continue;
        }

        x = realtime(a[i]["time"].ori - a[i-1]["time"].ori);
        split += "^1-" + x.min + ":" + x.sec + "." + x.milsec + "\n";
    }

    self setClientDvar("top20_leaderboard_number", number);
    self setClientDvar("top20_leaderboard_names", names);
    self setClientDvar("top20_leaderboard_times", times);
 
    number = "";
    names = "";
    times = "";
    split = "";

    if(!isDefined(a))
    	return;

    if(!isDefined(a.size))
    	return;

    l = a.size;

    if(l > 30)
        l = 30;
 
    for(i = 20; i < l; i++)
    {
        n = i; n++;
        number += "#" + n + "\n";
        colour = "^7";

        for(z = 0; z < level.vipList.size; z++)
        {
            if(a[i]["guid"] == level.vipList[z])
            {
                colour = "^2";
                break;
            }
        }

        if(a[i]["name"].size > 16 )
            names += colour+GetSubStr(a[i]["name"], 0, 15)+"\n";
        else
            names += colour+a[i]["name"] + "\n";
        times += a[i]["time"].min + ":" + a[i]["time"].sec + "." + a[i]["time"].milsec + "\n";

        if(i == 0)
        {
            split += "\n";
            continue;
        }

        x = realtime(a[i]["time"].ori - a[i-1]["time"].ori);
        split += "^1-" + x.min + ":" + x.sec + "." + x.milsec + "\n";
    }

    self setClientDvar("top30_leaderboard_number", number);
    self setClientDvar("top30_leaderboard_names", names);
    self setClientDvar("top30_leaderboard_times", times);
}

sortTimes(a)
{
	p = undefined;
	l = a.size;
	
	for(i = 0; i < l; i++)
	{
		for(z = 0; z < l; z++)
		{
			if(i != z && a[i]["guid"] == a[z]["guid"])
			{
				if(a[i]["time"].ori <= a[z]["time"].ori)
					p = z;
			}
		}
	}

	if(isDefined(p))
		a = removeFromArray(a, p);

	l = a.size;
	temp = 0;

	for(i = 0; i < l; i++)
	{
		for(z = 0; z < l - 1; z++)
		{
			if(a[z]["time"].ori > a[z+1]["time"].ori)
			{
				temp = a[z+1];
				a[z+1] = a[z];
				a[z] = temp;
			}
		}
	}

	return a;
}

removeFromArray(b, num)
{
	temp = [];

	for(i = 0; i < b.size; i++)
	{
		if(i != num)
			temp[temp.size] = b[i];
	}

	return temp;
}

realtime(number)
{
	time = SpawnStruct();

	time.ori = number;
    time.milsec = number;
    time.min = int(time.milsec/60000);
    time.milsec = time.milsec % 60000;
    time.sec = int(time.milsec/1000);
    time.milsec = time.milsec % 1000;

    return time;
}
