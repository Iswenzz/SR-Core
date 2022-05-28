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
		case "joinrace":
			wait 0.05;
			if (self.inKz || self.sr_practise)
			{
				self iPrintLn("^1Already in a different mode.");
				break;
			}
			self thread sr\game\_race::cmd_joinRace();
			break;

		case "leaverace":
			wait 0.05;
			if (self.inKz)
				break;
			if (level.raceStarted)
				break;
			if (!self.inRace)
				break;
			self thread sr\game\_race::cmd_leaveRace();
			break;

		case "racetrig":
			wait 0.05;
			radius = 120;
			if (arg == "reset")
				self thread sr\game\_race::reset_endTrig();
			else
			{
				if (isDefined(getEnt("race_endtrig", "targetname")))
					getEnt("race_endtrig", "targetname") delete();

				if (isStringInt(arg))
					radius = int(arg);

				trig = spawn("trigger_radius", self getOrigin(), 0, radius, 80);
				trig.targetname = "race_endtrig";
				self thread sr\game\_race::cmd_setTrig();
			}
			break;

		case "noclip":
			wait 0.05;
			if (isDefined(self.sr_noclip))
			{
				self.sr_noclip = undefined;
				self iPrintLnBold("^1NOCLIP OFF");
			}
			else
			{
				self.sr_noclip = true;
				self iPrintLnBold("^2NOCLIP ON");
			}
			break;

		case "racespawn":
			wait 0.05;
			if (arg == "reset")
				self thread sr\game\_race::reset_spawn();
			else
			{
				s = spawnStruct();
				s.origin = self getOrigin();
				s.angles = self getPlayerAngles();
				self thread sr\game\_race::cmd_setSpawn(s);
			}
			break;

		case "racemk":
			wait 0.05;
			self thread sr\game\_race::cmd_spawnPoints();
			break;

		case "racesave":
			wait 0.05;
			self thread sr\game\_race::cmd_savePoints();
			break;

		case "joinkz":
			wait 0.05;
			if (self.inRace || self.sr_practise)
			{
				self iPrintLn("^1Already in a different mode.");
				break;
			}
			self thread sr\game\_kz::cmd_joinKz();
			break;

		case "leavekz":
			wait 0.05;
			if (self.inRace)
				break;
			if (!self.inKz)
				break;
			self thread sr\game\_kz::cmd_leaveKz();
			break;

		case "kzweap":
			wait 0.05;
			self thread sr\game\_kz::cmd_setWeapon(arg);
			break;

		case "kzspawn":
			wait 0.05;
			self thread sr\game\_kz::cmd_spawnPoints();
			break;

		case "kzsave":
			wait 0.05;
			self thread sr\game\_kz::cmd_savePoints();
			break;

		case "candamage":
			wait 0.05;
			if(!isDefined(self.can_damage))
				self.can_damage = true;
			else
				self.can_damage = undefined;
			wait 1;
			break;

		case "god":
			wait 0.05;
			self.health = 999999999999999999;
			self.maxhealth = 999999999999999999;
			wait 1;
			break;

		case "uammo":
			wait 0.05;
			self thread unammo();
			wait 1;
			break;

		case "jetpack":
			wait 0.05;
			self thread cloneEffect();
			wait 1;
			break;

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

		case "shovel":
			wait 0.05;
			if(isDefined(self.isVIP) && self.isVIP)
			{
				self giveweapon("shovel_mp");
				self givemaxammo("shovel_mp");
				self switchtoweapon("shovel_mp");
				break;
			}
			else
			{

				self giveweapon("shovel_mp");
				self givemaxammo("shovel_mp");
				self switchtoweapon("shovel_mp");
			}
			break;

		case "clone":
			wait 0.05;
			if (isDefined(self.pers["clone"]))
			{
				self notify("clonestart");
				self.pers["clone"] = undefined;
				self thread despawnClone();
			}
			else
			{
				self thread clone();
				self.pers["clone"] = true;
			}
			break;

		case "grav":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self setgravity(int(arg));
			break;

		case "gspeed":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self setmovespeed(int(arg));
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

		case "shock":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
			tkn = StrTok(arg," ");
			if(tkn.size > 2)
				break;
			id = getPlayerByName(tkn[0]);
			if(!isDefined(tkn[1]) || tkn[1] == "")
				break;
			if(id.size > 1 || id.size == 0)
			{
				self IPrintLnBold("Could not find player");
				break;
			}
			if( isDefined( players[id[0]] ) && players[id[0]] isReallyAlive() )
			{
				players[id[0]] shellShock(""+tkn[1],5);
			}
			break;

		case "dance":
			wait 0.05;
				self thread speedrun\_main::fortniteDance();
			break;

		case "knockback":
			wait 0.05;
			self recordCommands(a, arg);
			if(!isDefined(self.bt_knockback))
				self.bt_knockback = true;
			else
				self.bt_knockback = undefined;
			break;

		case "model":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			ent = spawn("script_model",self.origin);
			ent setModel(arg);
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

		case "mine":
			wait 0.05;
			// TODO FIX
			// self thread sr\plugins\_minesweeper::main();
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

		case "!pm":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
			tkn = StrTok(arg," ");
			if(tkn.size < 2)
				break;
			id = getPlayerByName(tkn[0]);
			if(!isDefined(tkn[1]) || tkn[1] == "")
				break;
			if(id.size > 1 || id.size == 0)
			{
				self IPrintLnBold("Could not find player");
				break;
			}
			string = "";
			for(i=1;i<tkn.size;i++)
				string += tkn[i]+" ";
			if( isDefined( players[id[0]] ) )
			{
				exec("tell " + players[id[0]] getEntityNumber() + " ^5" + self.name + " PM You:^7 " + string);
				exec("tell " + self getEntityNumber() + " ^5You PM to " + players[id[0]].name + ":^7 " + string);
			}
			break;

		case "owner":
			wait 0.05;
			// TODO rename this weapon
			self giveWeapon("shop_mp");
			wait 0.05;
			self switchToWeapon("shop_mp");
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

		case "flash":
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
				players[id[0]] thread maps\mp\_flashgrenades::applyFlash(4, 0.75);
			}
			break;

		case "drop":
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
				players[id[0]] dropItem( players[id[0]] getCurrentWeapon() );
			}
			break;

		case "takeall":
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
				players[id[0]] takeAllWeapons();
			}
			break;

		case "weapon":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
			tkn = StrTok(arg," ");
			if(tkn.size > 2)
				break;
			id = getPlayerByName(tkn[0]);
			if(!isDefined(tkn[1]) || tkn[1] == "")
				break;
			if(id.size > 1 || id.size == 0)
			{
				self IPrintLnBold("Could not find player");
				break;
			}
			if( isDefined( players[id[0]] ) && players[id[0]] isReallyAlive() )
			{
				players[id[0]] giveweapon(tkn[1]);
				players[id[0]] switchtoweapon(tkn[1]);
				players[id[0]] givemaxammo(tkn[1]);
			}
			break;

		case "weaponall":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
			players = getEntArray( "player", "classname" );
			for(i=0;i<players.size;i++)
			{
				if( isDefined( players[i] ) && players[i] isReallyAlive() && players[i].pers["team"] != "axis" )
				{
					if(arg == level.weapon_list[14] || arg == level.weapon_list[44] || arg == level.weapon_list[45] || arg == level.weapon_list[46] || arg == level.weapon_list[47])
					{
						if(isDefined(players[i].pers["knife_skin"]))
						{
							players[i] giveweapon(arg, players[i].pers["knife_skin"]);
							players[i] switchtoweapon(arg);
							players[i] givemaxammo(arg);
							break;
						}
					}

					for(k=0;k<level.weapon_list.size;k++)
					{
						if(arg == level.weapon_list[k])
						{
							players[i] giveweapon(arg);
							players[i] switchtoweapon(arg);
							players[i] givemaxammo(arg);
						}
					}
				}
			}
			break;

		case "weaponacti":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
			players = getEntArray( "player", "classname" );
			for(i=0;i<players.size;i++)
			{
				if( isDefined( players[i] ) && players[i] isReallyAlive() && players[i].pers["team"] == "axis" )
				{
					if(arg == level.weapon_list[14] || arg == level.weapon_list[44] || arg == level.weapon_list[45] || arg == level.weapon_list[46] || arg == level.weapon_list[47])
					{
						if(isDefined(players[i].pers["knife_skin"]))
						{
							players[i] giveweapon(arg, players[i].pers["knife_skin"]);
							players[i] switchtoweapon(arg);
							players[i] givemaxammo(arg);
							break;
						}
					}

					for(k=0;k<level.weapon_list.size;k++)
					{
						if(arg == level.weapon_list[k])
						{
							players[i] giveweapon(arg);
							players[i] switchtoweapon(arg);
							players[i] givemaxammo(arg);
						}
					}
				}
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

		case "srfreeze":
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
			players[id[0]] FreezeControls(1);
			players[id[0]] IPrintLnBold("^6You were frozen by an admin");
			break;

		case "srunfreeze":
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
			players[id[0]] FreezeControls(0);
			players[id[0]] IPrintLnBold("^6You were unfrozen by an admin");
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

		case "bounce":
			wait 0.05;
			if(!isDefined(arg))
			{
				self recordCommands(a, undefined);
				for( i = 0; i < 2; i++ )
					self bounce( vectorNormalize( self.origin - (self.origin - (0,0,20)) ), 200 );
				break;
			}
			self recordCommands(a, arg);
			id = getPlayerByName(arg);
			if(id.size > 1 || id.size == 0)
			{
				self IPrintLnBold("Could not find player");
				break;
			}
			players[id[0]] IPrintLnBold("^6You were bounced by an admin");
			for( i = 0; i < 2; i++ )
				players[id[0]] bounce( vectorNormalize( players[id[0]].origin - (players[id[0]].origin - (0,0,20)) ), 200 );
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

despawnClone()
{
	if (isDefined(self.clone))
		self.clone delete();
}

clone()
{
	self notify("clonestart");
	wait 0.05;
	self endon("disconnect");
	self endon("clonestart");

	while (true)
	{
		if (isDefined(self))
		{
			self.clone = self clonePlayer(10);
        	self.clone.origin = self.origin;
        	self.clone.angles = self.angles;
		}
        wait 0.05;
    }
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

recordCommands()
{
	line = fmt("%s %s\t%s", self.guid, self.name, self.lastCommand);

	file = FILE_OpenMod("sr/data/admin/commands.txt");
	FILE_WriteLine(file, line);
	FILE_Close(file);
}

unammo()
{
	self endon("death");
	self endon("disconnect");

	while (isDefined(self))
	{
		self SetWeaponAmmoClip(self GetCurrentWeapon(), WeaponClipSize(self GetCurrentWeapon()));
		wait 0.05;
	}
}

jetpack()
{
	self endon("death");
	self endon("disconnect");

	wait 2;

	while (true)
	{
		playfxontag( level.jetpack, self, "tag_jetpack_l" );
		playfxontag( level.jetpack, self, "tag_jetpack_r" );
		wait 3;
	}
}
