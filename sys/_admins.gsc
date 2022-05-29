#include sr\utils\_common;

init()
{
	precache();

	// Groups
	level.admin_group 					= [];
	level.admin_group["player"] 		= 1;
	level.admin_group["member"] 		= 10;
	level.admin_group["admin"] 			= 30;
	level.admin_group["adminplus"] 		= 50;
	level.admin_group["masteradmin"] 	= 60;
	level.admin_group["owner"] 			= 100;

	// Special
	level.special_group["vip"] 			= 1;
	level.special_group["donator"] 		= 2;

	// Commands
	level.admin_commands				= [];
}

precache()
{
	precacheModel("chicken");
	precacheModel("ad_sodamachine");
	precacheModel("afr_steel_ladder");
	precacheModel("ap_airbus_seat_1");
	precacheModel("axis");
	precacheModel("bathroom_toilet");
	precacheModel("bc_militarytent_draped");
	precacheModel("ch_apartment_9story_noentry_02");
	precacheModel("ch_banner_large");
	precacheModel("ch_crate64x64");
	precacheModel("ch_dead_cow");
	precacheModel("ch_piano_light");
	precacheModel("ch_roadrock_06");
	precacheModel("ch_russian_table");
	precacheModel("ch_street_light_02_off");
	precacheModel("cobra_town_brown_car");
	precacheModel("com_barrel_biohazard");
	precacheModel("com_bookshelves1");
	precacheModel("com_computer_monitor");
	precacheModel("com_widescreen_monitor_on_2");
	precacheModel("projectile_sidewinder_missile");
	precacheModel("prop_flag_russian");
	precacheModel("prop_flag_neutral");
	precacheModel("vehicle_blackhawk");
	precacheModel("vehicle_bm21_mobile_cover");

	precacheShellShock("death");
	precacheShellShock("concussion_grenade_mp");
}

commands(cmd, arg)
{
	if (!self canExecuteCommand(cmd))
		return;

	switch(a)
	{
		case "detonate":
			wait 0.05;
			self.detonate = true;
			wait 1;
			break;

		case "delturret":
			wait 0.05;
			for(i=0;i<level.portal_turrets.size;i++)
			{
				level.portal_turrets[i] sr\weapons\_portal_turret::explode("MOD_EXPLOSIVE");
				wait 1;
				level.portal_turrets[i] sr\weapons\_portal_turret::delete_turret();
			}
			wait 1;
			break;

		case "turret":
			wait 0.05;
			self thread braxi\_common::clientcmd("centerview");
			wait 0.2;
			thread sr\weapons\_portal_turret::spawn_turret( self.origin, self getPlayerAngles() );
			wait 1;
			break;

		case "color":
			wait 0.05;
			if(!isDefined(self.isVIP))
				break;
			if(!self.isVIP)
				break;
			tkn = StrTok(arg," ");
			if(tkn.size != 3)
				break;
			self setStat(1650,int(tkn[0]));
			self setStat(1651,int(tkn[1]));
			self setStat(1652,int(tkn[2]));
			wait 0.1;
			self suicide();
			break;

		case "chicken":
			wait 0.05;
			ent = spawn("script_model",self.origin);
			ent setModel("chicken");
			ent.realModel = "chicken";
			break;

		case "savechicken":
			wait 0.05;
			map = getDvar("mapname");
			model = getEntArray("script_model","classname");
			string = "";
			chicken = 0;
			wait 0.5;
			for(i=0;i<model.size;i++)
			{
				if(isDefined(model[i].realModel) && model[i].realModel == "chicken")
				{
					string += ""+chicken+"\\"+model[i].origin[0]+"\\"+model[i].origin[1]+"\\"+model[i].origin[2]+"\n";
					chicken++;
				}
				wait 0.2;
			}
			path = "./sr/server_data/speedrun/chicken/"+map+".txt";
			file_exists = checkfile(path);
			if(!file_exists)
			{
				WriteToFile(path, string);
				wait 0.5;
			}
			else
			{
				deleteFile_late(path);
				wait 0.5;
				WriteToFile(path, string);
				wait 0.5;
			}
			self iprintlnbold("Chicken saved!");
			break;

		case "savemap":
			wait 0.05;
			map = getDvar("mapname");
			brush = getEntArray("script_brushmodel","classname");
			string = [];
			index = 0;
			wait 0.5;
			for(i=0;i<brush.size;i++)
			{
				if(isDefined(brush[i]) && isDefined(brush[i].targetname) && isDefined(getEntArray(brush[i].targetname,"targetname").size) && getEntArray(brush[i].targetname,"targetname").size > 1)
				{
					brush_def = getEntArray(brush[i].targetname,"targetname");

					for(j=0;j<brush_def.size;j++)
					{
						if(isDefined(brush_def[j]) && isDefined(brush_def[j].targetname))
						{
							string[index] = ""+int(index)+"\\"+brush_def[j].origin[0]+"\\"+brush_def[j].origin[1]+"\\"+brush_def[j].origin[2]+"\\"+brush_def[j].angles[0]+"\\"+brush_def[j].angles[1]+"\\"+brush_def[j].angles[2]+"\\"+brush_def[j].targetname+"\\"+j;
							index++;
						}
					}
				}

				else
				{
					if(isDefined(brush[i]) && isDefined(brush[i].targetname))
					{
						string[index] = ""+index+"\\"+brush[i].origin[0]+"\\"+brush[i].origin[1]+"\\"+brush[i].origin[2]+"\\"+brush[i].angles[0]+"\\"+brush[i].angles[1]+"\\"+brush[i].angles[2]+"\\"+brush[i].targetname+"\\"+"1";
						index++;
					}
				}

				wait 0.05;
			}
			path = "./sr/server_data/speedrun/saved_map/"+map+".txt";
			file_exists = checkfile(path);
			if(!file_exists)
			{
				for(i=0;i<string.size;i++)
				{
					if(isDefined(string[i]) && string[i] != "")
						WriteToFile(path, string[i]);
				}

				wait 0.5;
			}
			else
			{
				deleteFile_late(path);
				wait 0.5;

				for(i=0;i<string.size;i++)
				{
					if(isDefined(string[i]) && string[i] != "")
						WriteToFile(path, string[i]);
				}

				wait 0.5;
			}
			self iprintlnbold("Map saved!");
			break;

		case "fps":
			wait 0.05;
			if(self.pers["fullbright"] == 0)
			{
				self.pers["fullbright"] = 1;
				self setClientDvar( "r_fullbright", 1 );
				self IPrintLnBold("^2Fullbright On");
				self thread sr\player\_options::updateSettings();
			}
			else
			{
				self.pers["fullbright"] = 0;
				self setClientDvar( "r_fullbright", 0 );
				self IPrintLnBold("^1Fullbright Off");
				self thread sr\player\_options::updateSettings();
			}
			break;

		case "practise":
			wait 0.05;
			if (self.inRace || self.inKz)
				break;
			if(self.sr_cheatmode)
			{
				self.sr_cheatmode = false;
				self.sr_practise = false;
				self IPrintLnBold("^1Practise mode disabled!");
				self Suicide();
			}
			else if(!self.sr_cheatmode)
			{
				self.sr_cheatmode = true;
				self.sr_practise = true;
				self IPrintLnBold("^2Practise mode enabled!");
				self IPrintLnBold("Press [{+melee}] to save position");
				self IPrintLnBold("Press [{+activate}] to load positon");
				self Suicide();
			}
			break;

		case "speed":
			wait 0.05;
			if (self.inRace || self.inKz)
				break;
			if(self.sr_speed == 190)
			{
				self.sr_speed = 210;
				self IPrintLnBold("Move speed set to 210");
				self Suicide();
			}
			else if(self.sr_speed == 210)
			{
				self.sr_speed = 190;
				self IPrintLnBold("Move speed set to 190");
				self Suicide();
			}
			break;

		case "fov":
			wait 0.05;
			if(arg == "")
			{
				self iprintlnbold("^5command usage example: ^7!fov 1.292");
				break;
			}
			if(!isDefined(arg) || arg == "" || !isStringFloat(arg))
				break;
			self.fovscale = FloatFov(arg);
			if(self.fovscale > 2000)
				break;
			if(self.fovscale < 200)
				break;
			self setClientDvar("cg_fovscale", arg);
			self IPrintLnBold("^5FOV scale ^7" + arg);
			self.pers["fovscale"] = self.fovscale;
			self thread sr\player\_options::updateSettings();
			break;

		case "fxenable":
			if(self.pers["fxenabled"] == 0)
			{
				self.pers["fxenabled"] = 1;
				self setClientDvar("fx_enable", 1);
				self IPrintLnBold("^2FX enabled");
			}
			else
			{
				self.pers["fxenabled"] = 0;
				self setClientDvar("fx_enable", 0);
				self IPrintLnBold("^1FX disabled");
			}
			break;

		case "discord":
			wait 0.05;
			exec( "tell " + self getEntityNumber() + " Join Sr- Discord: ^5discord.gg/76aHfGF" );
			wait 0.2;
			break;

		case "requirement":
			wait 0.05;
			exec( "tell " + self getEntityNumber() + " Check #sr-requirement channel in our discord: ^5discord.gg/76aHfGF" );
			wait 0.2;
			break;

		case "sheep":
			wait 0.05;
			for(i=0; i<50; i++)
			{
				self IPrintLnBold("^3S^2h^1e^4e^6p ^3w^2i^1z^4a^6r^5d");
				wait 0.2;
				i++;
			}
			self setClientDvar("r_specular", 1);
			self setClientDvar("r_specularmap", 2);
			break;

		case "kill":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
			id = getPlayerByName(arg);
			if(id.size > 1 || id.size == 0)
			{
				self IPrintLnBold("Could not find player");
				break;
			}
			if( isDefined( players[id[0]] ) && players[id[0]] isReallyAlive() )
			{
				players[id[0]] Suicide();
				players[id[0]] IPrintLnBold("^6You were killed by an admin");
			}
			break;

		case "votemap":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
			if (isSubStr(arg, " ") || !isSubStr(arg, "mp_"))
				thread sr\commands\_map_vote::startvote("msg", arg);
			else
				thread sr\commands\_map_vote::startvote("map", arg);
			break;

		case "timeplayed":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
			id = getPlayerByName(arg);
			if(id.size > 1 || id.size == 0)
			{
				self IPrintLnBold("Could not find player");
				break;
			}
			if( isDefined( players[id[0]] ) )
			{
				playtime = int(players[id[0]] getstat(2314));
				exec( "tell " + self getEntityNumber() + " " + players[id[0]].name + " played " + playtime + " on this server." );
			}
			break;
	}
}

cmd(group, name)
{
	cmdGroup = IfDefined(level.admin_group[group], level.special_group[group]);
	level.admin_commands[name] = cmdGroup;
	
	addScriptCommand(name, 1);
}

message(msg)
{
	exec(fmt("say %s", msg));
}

pm(msg)
{
	exec(fmt("tell %d %s", self getEntityNumber(), msg));
}

canExecuteCommand(cmd)
{
	return false;
}

getGroupString()
{
	group = "^7Player";
	switch (self.admin_group)
	{
		case "owner":
			group = "^5Owner";
			break;
		case "masteradmin":
			group = "^9Master Admin";
			break;
		case "adminplus":
			group = "^1Admin+";
			break;
		case "admin":
			group = "^6Admin";
			break;
		case "member":
			group = "^3Member";
			break;
	}
	return group;
}

hasPower(group)
{
	return self getPlayerPower() >= level.admin_group[group];
}

isVIP()
{
	return isDefined(self.isVIP) && self.isVIP;
}

getPlayerPower()
{
	return self.admin_power;
}

setPlayerPower(power)
{
	self.admin_power = power;
}

checkBanned()
{
	self endon("disconnect");
	self.guid = getSubStr(self getGuid(), 24, 32);

	path = "./sr/server_data/admin/ban.txt";
	file_exists = checkfile(path);
	if(!file_exists)
		return;
	r = readAll(path);
	for(i=0; i<r.size; i++)
	{
		a = StrTok(r[i],"\\");
		if(isDefined(a[0]))
		{
			if(self.guid == a[0])
			{
				self thread banned();
				return true;
			}
		}
	}
	return false;
}

banned()
{
	self setClientDvar("ui_dr_info", "^4You have been banned.");
	self setClientDvar("ui_dr_info2", "^5More info at https://discord.gg/76aHfGF");
	// Use this instead of kick() to get the ui_dr_info menu
	exec("kick " + self getEntityNumber() + " banned.");
}

getPlayerByNum(pNum) 
{
	found = [];
	players = getAllPlayers();

	for (i = 0; i < players.size; i++)
	{
		if (players[i] getEntityNumber() == IfDefined(ToInt(pNum), -1))
			found[found.size] = players[i];
	}
	return found;
}

getPlayerByName(nickname)
{
	found = [];
	players = getAllPlayers();

	for ( i = 0; i < players.size; i++ )
	{
		if (isSubStr(toLower(players[i].name), toLower(nickname)))
			found[found.size] = players[i];
	}
	return found;
}

log()
{
	line = fmt("%s %s\t%s", self.guid, self.name, self.lastCommand);

	file = FILE_OpenMod("sr/data/admin/commands.txt");
	FILE_WriteLine(file, line);
	FILE_Close(file);
}
