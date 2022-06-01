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

// TODO rename this file sr\api\_map + change the name in all gsc file + GSC Parser.

create_normal_way(token)
{
	level.new_leaderboard = true;
	way = strTok(token,";");

	for(i = 0; i < way.size; i++)
		createWay("normal", way[i], i+1);
}

create_secret_way(token)
{
	level.new_leaderboard = true;
	way = strTok(token,";");

	for(i = 0; i < way.size; i++)
		createWay("secret", way[i], i+1);
}

createWay(way, sname, number)
{
	if(!isDefined(level.normal_way))
	{
		level.normal_way = [];
		level.normal_way_info_190 = [];
		level.normal_way_info_210 = [];
	}

	if(!isDefined(level.secret_way))
	{
		level.secret_way = [];
		level.secret_way_info_190 = [];
		level.secret_way_info_210 = [];
	}

	// normal = left side of the menu
	// secret = right side of the menu

	// sname = the name of the button in menu
	// number = number of the way

	if(way == "normal")
	{
		level.normal_way[int(number)-1] = SpawnStruct();
		level.normal_way[int(number)-1].name = sname;
		level.normal_way[int(number)-1].path190 = "./sr/data/speedrun/map_times/"+getDvar("mapname")+"_fastesttimes_ns"+(int(number)-1)+"_190.txt";
		level.normal_way[int(number)-1].path210 = "./sr/data/speedrun/map_times/"+getDvar("mapname")+"_fastesttimes_ns"+(int(number)-1)+"_210.txt";
	}

	if(way == "secret")
	{
		level.secret_way[int(number)-1] = SpawnStruct();
		level.secret_way[int(number)-1].name = sname;
		level.secret_way[int(number)-1].path190 = "./sr/data/speedrun/map_times/"+getDvar("mapname")+"_fastesttimes_s"+(int(number)-1)+"_190.txt";
		level.secret_way[int(number)-1].path210 = "./sr/data/speedrun/map_times/"+getDvar("mapname")+"_fastesttimes_s"+(int(number)-1)+"_210.txt";
	}
}

way_name_default()
{
	for(i = 0; i < 7; i++)
	{
		self setClientDvar("s_normal_"+i,"0");
		self setClientDvar("s_normal_"+i+"_name","-");
		self setClientDvar("s_secret_"+i,"0");
		self setClientDvar("s_secret_"+i+"_name","-");
	}
}

change_way(way)
{
	if(	way == "ns0" ||
		way == "ns1" ||
		way == "ns2" ||
		way == "ns3" ||
		way == "ns4" ||
		way == "ns5" ||
		way == "s0" ||
		way == "s1" ||
		way == "s2" ||
		way == "s3" ||
		way == "s4" ||
		way == "s5"
	)
	{
		self.sr_way = way;
		self playLocalSound("change_way");
	}
}

finish_way(way)
{
	if( way == "ns1" ||
		way == "ns2" ||
		way == "ns3" ||
		way == "ns4" ||
		way == "ns5" ||
		way == "s0" ||
		way == "s1" ||
		way == "s2" ||
		way == "s3" ||
		way == "s4" ||
		way == "s5"
	)
	{
		if(self.sr_way == way)
			self thread braxi\_mod::endTimer();
	}
}

////////////////////////////////////////////////////////////////

create_endmap(trig_ori,width,height,way)
{
	if (!isDefined(way)) // normal way #1 default end
	{
		if(isDefined(getEnt("endmap_trig","targetname")))
		{
			temp = getEnt("endmap_trig","targetname");
			temp delete();
		}

		trig = spawn("trigger_radius",trig_ori,0,width,height);
		trig.targetname = "endmap_trig";
		trig.radius = width;
	}
	else
	{
		trig = spawn("trigger_radius",trig_ori,0,width,height);
		trig.radius = width;
		create_endmap_loop(trig, way);
	}

	wait 1;

	thread sr\game\fx\_trigger::createTrigFx(trig, "red");
}

create_endmap_loop(trig, way)
{
	for(;;)
	{
		trig waittill("trigger",player);

		if (isDefined(way))
			player finish_way(way);
	}
}

create_tp(trig_ori,width,height,ori,ori_angles,state,color,way)
{
	trig = spawn("trigger_radius",trig_ori,0,width,height);
	trig.radius = width;

	thread create_tp_loop(trig,ori,ori_angles,state,way);

	wait 1;

	if (!isDefined(color))
		thread sr\game\fx\_trigger::createTrigFx(trig, "blue");
	else
		thread sr\game\fx\_trigger::createTrigFx(trig, color);
}

create_tp_loop(trig,ori,ori_angles,state,way)
{
	for(;;)
	{
		trig waittill("trigger",player);

		if (isDefined(way))
			player change_way(way);

		if(state == "freeze")
		{
			player thread create_tp_loop_safe(ori,ori_angles);
		}

		else
		{
			player setOrigin(ori);
			player setPlayerAngles((0,ori_angles,0));
		}
	}
}

create_tp_loop_safe(ori,ori_angles)
{
	self endon("death");
	self endon("disconnect");

	self freezeControls(1);
	self setOrigin(ori);
	self setPlayerAngles((0,ori_angles,0));
	wait 0.05;
	self freezeControls(0);
}

create_spawn(ori,ori_angles)
{
	wait 0.05;

	level.masterSpawn = spawn("script_origin",(ori[0],ori[1],ori[2]-60));
	level.masterSpawn.angles = (0,ori_angles,0);
}

create_spawn_auto()
{
	auto_spawn = getEntArray("mp_jumper_spawn", "classname");
	if(!auto_spawn.size)
		return;

	ori = auto_spawn[int(auto_spawn.size / 2)].origin;
	angle = auto_spawn[int(auto_spawn.size / 2)].angles[1];

	wait 0.05;

	level.masterSpawn = spawn("script_origin", ori);
	level.masterSpawn.angles = (0, angle, 0);
}

// --------------------------------------------------------------- //
// ----------------- LEGACY FUNCTIONS DEPRECATED ----------------- //
// --------------------------------------------------------------- //

// DEPRECATED
create_secret(trig_ori,width,height,ori,ori_angles,state)
{
	trig = spawn("trigger_radius",trig_ori,0,width,height);
	trig.targetname = "sr_secret_trig";
	trig.radius = width;

	thread create_secret_loop(trig,ori,ori_angles,state);

	wait 1;

	thread sr\game\fx\_trigger::createTrigFx(trig, "blue");
}

// DEPRECATED
create_secret_loop(trig,ori,ori_angles,state)
{
	for(;;)
	{
		trig waittill("trigger",player);

		if(state == "freeze")
		{
			player thread create_secret_loop_safe(ori,ori_angles);
		}

		else
		{
			player sr\api\_map::startSecret();
			player setOrigin(ori);
			player setPlayerAngles((0,ori_angles,0));
		}
	}
}

// DEPRECATED
create_secret_loop_safe(ori,ori_angles)
{
	self endon("death");
	self endon("disconnect");

	self sr\api\_map::startSecret();
	self freezeControls(1);
	self setOrigin(ori);
	self setPlayerAngles((0,ori_angles,0));
	wait 0.05;
	self freezeControls(0);
}

// DEPRECATED
way_connect(normalway,secretway)
{
	if(normalway > 1 || secretway > 1)
		return;

	// Legacy function that isnt used anymore, except for all the GSC before the new
	// leaderboard update.

    wait 0.05;

    createWay("normal", "Normal Way", "1");

    if(secretway == 1)
		createWay("secret", "Secret Way", "1");

    for(;;)
    {
        level waittill( "connected", player );
        player thread way_name();
    }
}

// DEPRECATED
way_name()
{
	self endon("disconnect");
	self endon("joined_spectators");

	// s_normal_* = dvars for the menu button ID and name

	if(isDefined(level.normal_way))
	{
		for(i = 0; i < level.normal_way.size; i++)
		{
			self setClientDvar("s_normal_"+i,1);
			self setClientDvar("s_normal_"+i+"_name",level.normal_way[i].name);
		}
	}

	if(isDefined(level.secret_way))
	{
		for(i = 0; i < level.secret_way.size; i++)
		{
			self setClientDvar("s_secret_"+i,1);
			self setClientDvar("s_secret_"+i+"_name",level.secret_way[i].name);
		}
	}
}

// DEPRECATED
startSecret()
{
	// Legacy function that isnt used anymore, except for all the GSC before the new
	// leaderboard update.

	self.sr_secret = true;
	self playLocalSound("change_way");
}
