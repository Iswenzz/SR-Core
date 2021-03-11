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

loadTImes()
{
	mapname = getDvar("mapname");
	wait 1;

	debug("Loading Times");

	if (isDefined(level.normal_way) && isDefined(level.normal_way.size))
	{
		for(i = 0; i < level.normal_way.size; i++)
		{
			if(FS_TestFile(level.normal_way[i].path190))
				level.normal_way_info_190[i] = setVariables(level.normal_way_info_190[i],level.normal_way[i].path190);

			if(FS_TestFile(level.normal_way[i].path210))
				level.normal_way_info_210[i] = setVariables(level.normal_way_info_210[i],level.normal_way[i].path210);
		}
	}

	if (isDefined(level.secret_way) && isDefined(level.secret_way.size))
	{
		for(i = 0; i < level.secret_way.size; i++)
		{
			if(FS_TestFile(level.secret_way[i].path190))
				level.secret_way_info_190[i] = setVariables(level.secret_way_info_190[i],level.secret_way[i].path190);

			if(FS_TestFile(level.secret_way[i].path210))
				level.secret_way_info_210[i] = setVariables(level.secret_way_info_210[i],level.secret_way[i].path210);
		}
	}
}

loadPersonBest()
{
	mapname = getDvar("mapname");
	path = "./server_data/speedrun/personbest/" + self.playerID + ".txt";
	file_exists = checkfile(path);

	if(!file_exists)
		return;

	r = readAll(path);

	for(i = 0; i < r.size; i++)
	{
		tkn = StrTok(r[i], "\\");

		if (isDefined(level.normal_way) && isDefined(level.normal_way.size))
		{
			for(j = 0; j < level.normal_way.size; j++)
			{
				if(tkn[0] == mapname+"_ns"+j+"_190")
				{
					self.pb_190["ns_"+j]["speed"] = tkn[1]; 
					self.pb_190["ns_"+j]["way"] = tkn[2];
					self.pb_190["ns_"+j]["time"] = realtime(int(tkn[3])); 
					self.pb_190["ns_"+j]["name"] = tkn[4]; 
					self.pb_190["ns_"+j]["guid"] = tkn[5];
					self.pb_190["ns_"+j]["runid"] = tkn[6];
				}

				if(tkn[0] == mapname+"_ns"+j+"_210")
				{
					self.pb_210["ns_"+j]["speed"] = tkn[1]; 
					self.pb_210["ns_"+j]["way"] = tkn[2];
					self.pb_210["ns_"+j]["time"] = realtime(int(tkn[3])); 
					self.pb_210["ns_"+j]["name"] = tkn[4]; 
					self.pb_210["ns_"+j]["guid"] = tkn[5];
					self.pb_210["ns_"+j]["runid"] = tkn[6];
				}
			}
		}

		if (isDefined(level.secret_way) && isDefined(level.secret_way.size))
		{
			for(j = 0; j < level.secret_way.size; j++)
			{
				if(tkn[0] == mapname+"_s"+j+"_190")
				{
					self.pb_190["s_"+j]["speed"] = tkn[1]; 
					self.pb_190["s_"+j]["way"] = tkn[2];
					self.pb_190["s_"+j]["time"] = realtime(int(tkn[3])); 
					self.pb_190["s_"+j]["name"] = tkn[4]; 
					self.pb_190["s_"+j]["guid"] = tkn[5];
					self.pb_190["s_"+j]["runid"] = tkn[6];
				}

				if(tkn[0] == mapname+"_s"+j+"_210")
				{
					self.pb_210["s_"+j]["speed"] = tkn[1]; 
					self.pb_210["s_"+j]["way"] = tkn[2];
					self.pb_210["s_"+j]["time"] = realtime(int(tkn[3])); 
					self.pb_210["s_"+j]["name"] = tkn[4]; 
					self.pb_210["s_"+j]["guid"] = tkn[5];
					self.pb_210["s_"+j]["runid"] = tkn[6];
				}
			}
		}
	}
}

setVariables(a,struc)
{
	string = "";
	r = readAll(struc);
	a = [];

	for(i = 0; i < r.size; i++)
		string += r[i]+"\n";

	tkn = StrTok(string, "\n");

	for(i = 0; i < tkn.size; i++)
	{
		tkn2 = StrTok(tkn[i], "\\");

		a[i]["speed"] = tkn2[0];
		a[i]["way"] = tkn2[1];
		a[i]["time"] = realtime(int(tkn2[2]));
		a[i]["name"] = tkn2[3];
		a[i]["guid"] = tkn2[4];
		a[i]["runid"] = tkn2[5];
	}

	return a;
}

top10Menu()
{
	self endon("disconnect");
	self notify("top10menu_end");
	self endon("top10menu_end");
	
	mySpeed = ""+self.sr_speed;
	filterSpeed = ""+self.sr_speed;
	filterNormal = "0";
	filterSecret = "none";
	string =  "" + mySpeed + ", " + level.normal_way[0].name;
	
	if(mySpeed == "190")
		displayTop10(level.normal_way_info_190[0]);

	else if(mySpeed == "210")
		displayTop10(level.normal_way_info_210[0]);
		
	self setClientDvar("top10_leaderboard_filter", string);

	while(1)
	{		
		self waittill("menuresponse", menu, response);

		if(menu == "sr_leaderboard")
		{
			tkn = StrTok(response, ":");

			if(tkn[1] == "none")
			{
				
			}

			if(tkn[1] == "190" || tkn[1] == "210" )
			{
				filterSpeed = tkn[1];
			}

			if(tkn[0] == "ns")
			{
				filterNormal = tkn[1];
				filterSecret = "none";
			}

			if(tkn[0] == "s")
			{
				filterSecret = tkn[1];
				filterNormal = "none";
			}
		}

		if(filterNormal != "none")
		{
			if(isDefined(level.normal_way[int(filterNormal)]))
				string = "" + filterSpeed + ", " + level.normal_way[int(filterNormal)].name;

			self setClientDvar("top10_leaderboard_filter", string);
			
			if(filterSpeed == "190")
				displayTop10(level.normal_way_info_190[int(filterNormal)]);

			if(filterSpeed == "210")
				displayTop10(level.normal_way_info_210[int(filterNormal)]);
		}

		else if(filterSecret != "none")
		{
			if(isDefined(level.secret_way[int(filterSecret)]))
				string = "" + filterSpeed + ", " + level.secret_way[int(filterSecret)].name;

			self setClientDvar("top10_leaderboard_filter", string);
			
			if(filterSpeed == "190")
				displayTop10(level.secret_way_info_190[int(filterSecret)]);

			if(filterSpeed == "210")
				displayTop10(level.secret_way_info_210[int(filterSecret)]);
		}

		wait 0.05;
	}
}

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

saveTimes()
{
	info = [];

	info["name"] = self.name;
	info["guid"] = self.playerID;
	info["time"] = self.time;
	info["way"] = self.sr_way;
	info["speed"] = self.sr_speed;
	info["runid"] = self.runNumber;

	way = isSubStr(info["way"],"ns");

	if(way)
	{
		way = strTok(info["way"],"ns");
		number = way[0];
		secret = false;
	}

	else
	{
		way = strTok(info["way"],"s");
		number = way[0];
		secret = true;
	}

	if(!secret)
		IPrintLn(self.name + " finished the map in " + self.time.min + ":" + self.time.sec + "." + self.time.milsec + " - " + self.sr_speed + " / " + level.normal_way[int(number)].name);
	
	if(secret)
		IPrintLn(self.name + " finished the map in " + self.time.min + ":" + self.time.sec + "." + self.time.milsec + " - " + self.sr_speed + " / " + level.secret_way[int(number)].name);
	
	if(info["speed"] == 190)
	{
		if(info["way"] == "ns0" || info["way"] == "ns1" || info["way"] == "ns2" || info["way"] == "ns3" || info["way"] == "ns4" || info["way"] == "ns5")
		{
			number = strTok(info["way"],"ns");

			if(isDefined(level.normal_way_info_190[int(number[0])]) && isDefined(level.normal_way_info_190[int(number[0])].size))
				level.normal_way_info_190[int(number[0])][level.normal_way_info_190[int(number[0])].size] = info;
			else
				level.normal_way_info_190[int(number[0])][0] = info;

			level.normal_way_info_190[int(number[0])] = sortTimes(level.normal_way_info_190[int(number[0])]);
			saveToFile(level.normal_way_info_190[int(number[0])],level.normal_way[int(number[0])].path190);
			savepersonalbest(info,"_ns"+int(number[0])+"_190");
		}

		else if(info["way"] == "s0" || info["way"] == "s1" || info["way"] == "s2" || info["way"] == "s3" || info["way"] == "s4" || info["way"] == "s5")
		{
			number = strTok(info["way"],"s");

			if(isDefined(level.secret_way_info_190[int(number[0])]) && isDefined(level.secret_way_info_190[int(number[0])].size))
				level.secret_way_info_190[int(number[0])][level.secret_way_info_190[int(number[0])].size] = info;
			else
				level.secret_way_info_190[int(number[0])][0] = info;

			level.secret_way_info_190[int(number[0])] = sortTimes(level.secret_way_info_190[int(number[0])]);
			saveToFile(level.secret_way_info_190[int(number[0])],level.secret_way[int(number[0])].path190);
			savepersonalbest(info,"_s"+int(number[0])+"_190");
		}
	}

	if(info["speed"] == 210)
	{
		if(info["way"] == "ns0" || info["way"] == "ns1" || info["way"] == "ns2" || info["way"] == "ns3" || info["way"] == "ns4" || info["way"] == "ns5")
		{
			number = strTok(info["way"],"ns");
			
			if(isDefined(level.normal_way_info_210[int(number[0])]) && isDefined(level.normal_way_info_210[int(number[0])].size))
				level.normal_way_info_210[int(number[0])][level.normal_way_info_210[int(number[0])].size] = info;
			else
				level.normal_way_info_210[int(number[0])][0] = info;

			level.normal_way_info_210[int(number[0])] = sortTimes(level.normal_way_info_210[int(number[0])]);
			saveToFile(level.normal_way_info_210[int(number[0])],level.normal_way[int(number[0])].path210);
			savepersonalbest(info,"_ns"+int(number[0])+"_210");
		}

		else if(info["way"] == "s0" || info["way"] == "s1" || info["way"] == "s2" || info["way"] == "s3" || info["way"] == "s4" || info["way"] == "s5")
		{
			number = strTok(info["way"],"s");
			
			if(isDefined(level.secret_way_info_210[int(number[0])]) && isDefined(level.secret_way_info_210[int(number[0])].size))
				level.secret_way_info_210[int(number[0])][level.secret_way_info_210[int(number[0])].size] = info;
			else
				level.secret_way_info_210[int(number[0])][0] = info;

			level.secret_way_info_210[int(number[0])] = sortTimes(level.secret_way_info_210[int(number[0])]);
			saveToFile(level.secret_way_info_210[int(number[0])],level.secret_way[int(number[0])].path210);
			savepersonalbest(info,"_s"+int(number[0])+"_210");
		}
	}
}

savepersonalbest(a, way)
{
	faster = false;
	newrecord = true;
	mapname = getDvar("mapname");
	path = "./server_data/speedrun/personbest/" + a["guid"] +".txt";
	file_exists = checkfile(path);

	if(!file_exists)
	{
		checkQueue();
		new = FS_Fopen(path, "write");
		FS_FClose(new);
	}

	r = readAll(path);
	x = r.size;

	for(i = 0; i < r.size; i++)
	{
		tkn = StrTok(r[i], "\\");

		if(tkn[0] == mapname + way)
		{
			if(int(tkn[3]) > a["time"].ori)
			{
				x = i;
				faster = true;
			}

			newrecord = false;
			break;
		}
	}

	if(faster || newrecord)
	{
		self thread check_savedemo();
		self giveXpForTop30(a);
		r[x] = mapname + way +"\\"+ a["speed"] +"\\" + a["way"] + "\\"+ a["time"].ori + "\\"+ a["name"] + "\\" + a["guid"] + "\\" + a["runid"];
		
		deleteFile(path);

		for(i=0; i<r.size; i++)
			WriteToFile(path, r[i]);
	}

	if(!faster && !newrecord)
		self speedrun\_speedrun::stoprecord_delete();
}

check_savedemo()
{
	if(self.sr_speed == 190)
    {
        if(self.sr_way == "ns0" || self.sr_way == "ns1" || self.sr_way == "ns2" || self.sr_way == "ns3" || self.sr_way == "ns4" || self.sr_way == "ns5")
        {
        	number = strTok(self.sr_way,"ns");

            if(level.normal_way_info_190[int(number[0])].size > 5)
            {
                if(self.time.ori <= level.normal_way_info_190[int(number[0])][4]["time"].ori)
                {
                	self.stop_demo = true;
					self speedrun\_speedrun::stoprecord_save();
				}
				else
					self speedrun\_speedrun::stoprecord_delete();
			}
			else
				self speedrun\_speedrun::stoprecord_save();
        }

        else if(self.sr_way == "s0" || self.sr_way == "s1" || self.sr_way == "s2" || self.sr_way == "s3" || self.sr_way == "s4" || self.sr_way == "s5")
        {
        	number = strTok(self.sr_way,"s");

            if(level.secret_way_info_190[int(number[0])].size > 5)
            {
                if(self.time.ori <= level.secret_way_info_190[int(number[0])][4]["time"].ori)
                {
                	self.stop_demo = true;
					self speedrun\_speedrun::stoprecord_save();
				}
				else
					self speedrun\_speedrun::stoprecord_delete();
			}
			else
				self speedrun\_speedrun::stoprecord_save();
        }
    }

    if(self.sr_speed == 210)
    {
        if(self.sr_way == "ns0" || self.sr_way == "ns1" || self.sr_way == "ns2" || self.sr_way == "ns3" || self.sr_way == "ns4" || self.sr_way == "ns5")
        {
        	number = strTok(self.sr_way,"ns");

            if(level.normal_way_info_210[int(number[0])].size > 5)
            {
                if(self.time.ori <= level.normal_way_info_210[int(number[0])][4]["time"].ori)
                {
                	self.stop_demo = true;
					self speedrun\_speedrun::stoprecord_save();
				}
				else
					self speedrun\_speedrun::stoprecord_delete();
			}
			else
				self speedrun\_speedrun::stoprecord_save();
        }

        else if(self.sr_way == "s0" || self.sr_way == "s1" || self.sr_way == "s2" || self.sr_way == "s3" || self.sr_way == "s4" || self.sr_way == "s5")
        {
        	number = strTok(self.sr_way,"s");

            if(level.secret_way_info_210[int(number[0])].size > 5)
            {
                if(self.time.ori <= level.secret_way_info_210[int(number[0])][4]["time"].ori)
                {
                	self.stop_demo = true;
					self speedrun\_speedrun::stoprecord_save();
				}
				else
					self speedrun\_speedrun::stoprecord_delete();
			}
			else
				self speedrun\_speedrun::stoprecord_save();
        }
    }
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

saveToFile(a, path)
{
	string = "";
	arr = [];
	mapname = getDvar("mapname");

    l = a.size;
	if(l > level.timesToSave)
		l = level.timesToSave;

    for(i=0; i<l; i++)
    {
    	string = a[i]["speed"] + "\\";
    	string += a[i]["way"] + "\\";
    	string += a[i]["time"].ori + "\\";
    	string += a[i]["name"] + "\\";
    	string += a[i]["guid"] + "\\";
    	string += a[i]["runid"];
    	arr[arr.size] = string;
    } 

    deleteFile(path);

    for(i=0; i<arr.size; i++)
    	WriteToFile(path,  arr[i] );
}

giveXpForTop30(b)
{
	multiplyer = 1;

	if(b["speed"] == 190)
    {
        if(b["way"] == "ns0" || b["way"] == "ns1" || b["way"] == "ns2" || b["way"] == "ns3" || b["way"] == "ns4" || b["way"] == "ns5")
        {
        	number = strTok(b["way"],"ns");

        	for(i = 0; i < level.normal_way_info_190[int(number[0])].size; i++)
        	{
        		if(b["time"].ori <= level.normal_way_info_190[int(number[0])][i]["time"].ori)
        		{
        			if(i < 30 && !isDefined(self.isVIP))
        			{
        				if(level.normal_way_info_190[int(number[0])].size > 27)
        					multiplyer = 27;
        				else
        					multiplyer = level.normal_way_info_190[int(number[0])].size;

        				self braxi\_rank::giveRankXP2((xpamount()[i] * multiplyer));
        				return;
        			}

        			if(i < 30 && isDefined(self.isVIP) && self.isVIP)
        			{
        				if(level.normal_way_info_190[int(number[0])].size > 27)
        					multiplyer = 27 * 3;
        				else
        					multiplyer = level.normal_way_info_190[int(number[0])].size * 3;

        				self braxi\_rank::giveRankXP2((xpamount()[i] * multiplyer));
        				return;
        			}
        		}
        	}
        }

        if(b["way"] == "s0" || b["way"] == "s1" || b["way"] == "s2" || b["way"] == "s3" || b["way"] == "s4" || b["way"] == "s5")
        {
        	number = strTok(b["way"],"s");

        	for(i = 0; i < level.secret_way_info_190[int(number[0])].size; i++)
        	{
        		if(b["time"].ori <= level.secret_way_info_190[int(number[0])][i]["time"].ori)
        		{
        			if(i < 30 && !isDefined(self.isVIP))
        			{
        				if(level.secret_way_info_190[int(number[0])].size > 27)
        					multiplyer = 27;
        				else
        					multiplyer = level.secret_way_info_190[int(number[0])].size;

        				self braxi\_rank::giveRankXP2((xpamount()[i] * multiplyer));
        				return;
        			}

        			if(i < 30 && isDefined(self.isVIP) && self.isVIP)
        			{
        				if(level.secret_way_info_190[int(number[0])].size > 27)
        					multiplyer = 27 * 3;
        				else
        					multiplyer = level.secret_way_info_190[int(number[0])].size * 3;

        				self braxi\_rank::giveRankXP2((xpamount()[i] * multiplyer));
        				return;
        			}
        		}
        	}
        }
    }

    if(b["speed"] == 210)
    {
        if(b["way"] == "ns0" || b["way"] == "ns1" || b["way"] == "ns2" || b["way"] == "ns3" || b["way"] == "ns4" || b["way"] == "ns5")
        {
        	number = strTok(b["way"],"ns");

        	for(i = 0; i < level.normal_way_info_210[int(number[0])].size; i++)
        	{
        		if(b["time"].ori <= level.normal_way_info_210[int(number[0])][i]["time"].ori)
        		{
        			if(i < 30 && !isDefined(self.isVIP))
        			{
        				if(level.normal_way_info_210[int(number[0])].size > 27)
        					multiplyer = 27;
        				else
        					multiplyer = level.normal_way_info_210[int(number[0])].size;

        				self braxi\_rank::giveRankXP2((xpamount()[i] * multiplyer));
        				return;
        			}

        			if(i < 30 && isDefined(self.isVIP) && self.isVIP)
        			{
        				if(level.normal_way_info_210[int(number[0])].size > 27)
        					multiplyer = 27 * 2;
        				else
        					multiplyer = level.normal_way_info_210[int(number[0])].size * 2;

        				self braxi\_rank::giveRankXP2((xpamount()[i] * multiplyer));
        				return;
        			}
        		}
        	}
        }

        if(b["way"] == "s0" || b["way"] == "s1" || b["way"] == "s2" || b["way"] == "s3" || b["way"] == "s4" || b["way"] == "s5")
        {
        	number = strTok(b["way"],"s");

        	for(i = 0; i < level.secret_way_info_210[int(number[0])].size; i++)
        	{
        		if(b["time"].ori <= level.secret_way_info_210[int(number[0])][i]["time"].ori)
        		{
        			if(i < 30 && !isDefined(self.isVIP))
        			{
        				if(level.secret_way_info_210[int(number[0])].size > 27)
        					multiplyer = 27;
        				else
        					multiplyer = level.secret_way_info_210[int(number[0])].size;

        				self braxi\_rank::giveRankXP2((xpamount()[i] * multiplyer));
        				return;
        			}

        			if(i < 30 && isDefined(self.isVIP) && self.isVIP)
        			{
        				if(level.secret_way_info_210[int(number[0])].size > 27)
        					multiplyer = 27 * 2;
        				else
        					multiplyer = level.secret_way_info_210[int(number[0])].size * 2;

        				self braxi\_rank::giveRankXP2((xpamount()[i] * multiplyer));
        				return;
        			}
        		}
        	}
        }
    }
}

xpamount()
{
	xp = [];

	xp[0] = 200;
	xp[1] = 180;
	xp[2] = 160;
	xp[3] = 150;
	xp[4] = 140;
	xp[5] = 130;
	xp[6] = 110;
	xp[7] = 100;
	xp[8] = 90;
	xp[9] = 85;
	xp[10] = 67;
	xp[11] = 55;
	xp[12] = 45;
	xp[13] = 40;
	xp[14] = 34;
	xp[15] = 30;
	xp[16] = 25;
	xp[17] = 22;
	xp[18] = 18;
	xp[19] = 15;
	xp[20] = 12;
	xp[21] = 10;
	xp[22] = 9;
	xp[23] = 8;
	xp[24] = 7;
	xp[25] = 6;
	xp[26] = 5;
	xp[27] = 3;
	xp[28] = 2;
	xp[29] = 1;

	return xp;
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

debug(msg)
{
	iprintlnbold("^1DEBUG: "+msg);
}