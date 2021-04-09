/*

  _|_|_|            _|      _|      _|                  _|            
_|        _|    _|    _|  _|        _|          _|_|    _|  _|_|_|_|  
  _|_|    _|    _|      _|          _|        _|    _|  _|      _|    
      _|  _|    _|    _|  _|        _|        _|    _|  _|    _|      
_|_|_|      _|_|_|  _|      _|      _|_|_|_|    _|_|    _|  _|_|_|_|  

Script made by Iswenzz (SuX Lolz)

Steam: https://steamcommunity.com/id/iswenzz
Discord: Iswenzz#3906
SR Discord: https://discord.gg/76aHfGF
Youtube: https://www.youtube.com/c/iswenzz
Paypal: alexisnardiello@gmail.com
Email Pro: alexisnardiello@gmail.com

*/
#include braxi\_common;
#include sr\sys\_gsxcommon;

init()
{
	precache();
	cmds();

	level.bot_record = 0;
	
	//               GROUP NAME         POWER
	level.admin_group 					= [];
	level.admin_group["player"] 		= 1;
	level.admin_group["donator"] 		= 5;
	level.admin_group["member"] 		= 10;
	level.admin_group["admin"] 			= 30;
	level.admin_group["adminplus"] 		= 50;
	level.admin_group["masteradmin"] 	= 60;
	level.admin_group["owner"] 			= 100;

	// 					GROUP NAME        ALLOWED COMMANDS
	level.admin_commands				= [];
	level.admin_commands["vip"] 		= "color,dance,msg,shovel";
	level.admin_commands["player"] 		= "fov,fps,myid,sheep,help,fxenable,!pm,discord,requirement,speed,practise,mine,joinrace,leaverace,joinkz,leavekz,stopmusic";
	level.admin_commands["donator"] 	= level.admin_commands["player"] + ",votemap,chiken";
	level.admin_commands["member"] 		= level.admin_commands["player"] + ",votemap,msg,online,timeplayed,reportplayer,reportmap,chicken,botrec,botswitch";
	level.admin_commands["admin"] 		= level.admin_commands["member"] + ",detail,pid,kill,srkick,renamepid";
	level.admin_commands["adminplus"] 	= level.admin_commands["admin"] + ",weapon,weaponall,weaponacti,drop,takeall,flash,shock,music";
	level.admin_commands["masteradmin"] = level.admin_commands["adminplus"] + ",resetpid,banpid,banguid,bounce,srfreeze,srunfreeze,cooldown,shovel,racetrig,racespawn,racemk,racesave,kzspawn,kzsave,kzweap,dance";
	level.admin_commands["owner"] 		= "*";

	musics();
}

// known sr music hashmap
musics()
{
	level.sr_music = [];
	level.sr_music["dame_tu_cosita"] 		= "srm1";
	level.sr_music["ways_to_die"] 			= "srm2";
	level.sr_music["this_is_minecraft"] 	= "srm3";
	level.sr_music["stal"] 					= "srm4";
	level.sr_music["fn_despacito"] 			= "srm5";
	level.sr_music["oof"] 					= "srm6";
	level.sr_music["mc"] 					= "srm7";
	level.sr_music["doot"] 					= "srm8";
	level.sr_music["despacito"] 			= "srm9";
	level.sr_music["dead"] 					= "srm10";
	level.sr_music["delfino"] 				= "srm11";
	level.sr_music["ninja"] 				= "srm12";
	level.sr_music["poopy"] 				= "srm13";
	level.sr_music["wii"] 					= "srm14";
	level.sr_music["ricardo"] 				= "srm15";
	level.sr_music["fishe"] 				= "srm16";
	level.sr_music["tense"] 				= "srm17";
	level.sr_music["cow"] 					= "srm18";
	level.sr_music["polish"] 				= "srm19";
	level.sr_music["minion"] 				= "srm20";
}

// all cmds
cmds()
{
	//player
	cmd("fov");
	cmd("fps");
	cmd("myid");
	cmd("sheep");
	cmd("help");
	cmd("fxenable");
	cmd("!pm");
	cmd("discord");
	cmd("requirement");
	cmd("speed");
	cmd("practise");
	cmd("mine");
	cmd("stopmusic");

	//member
	cmd("msg");
	cmd("online");
	cmd("timeplayed");
	cmd("reportplayer");
	cmd("reportmap");
	cmd("chicken");
	cmd("botrec");
	cmd("botswitch");
	cmd("joinrace");
	cmd("leaverace");
	cmd("joinkz");
	cmd("leavekz");
	
	//admin
	cmd("dance");
	cmd("detail");
	cmd("pid");
	cmd("kill");
	cmd("srkick");
	cmd("renamepid");
	cmd("racetrig");
	cmd("racespawn");
	cmd("kzweap");
	
	//adminplus
	cmd("weapon");
	cmd("weaponall");
	cmd("weaponacti");
	cmd("drop");
	cmd("takeall");
	cmd("flash");
	cmd("shock");
	cmd("music");
	cmd("votemap");
	
	//masteradmin
	cmd("resetpid");
	cmd("banpid");
	cmd("banguid");
	cmd("bounce");
	cmd("srfreeze");
	cmd("srunfreeze");
	cmd("cooldown");
	cmd("shovel");

	//owner
	cmd("clone");
	cmd("redirectall");
	cmd("candamage");
	cmd("turret");
	cmd("delturret");
	cmd("setrank");
	cmd("setgroup");
	cmd("setvip");
	cmd("savechicken");
	cmd("savemap");
	cmd("grav");
	cmd("gspeed");
	cmd("cmd");
	cmd("model");
	cmd("botrefresh");
	cmd("getdvar");
	cmd("setid");
	cmd("knockback");
	cmd("god");
	cmd("uammo");
	cmd("detonate");
	cmd("jetpack");
	cmd("owner");
	cmd("kzspawn");
	cmd("kzsave");
	cmd("racemk");
	cmd("racesave");
	cmd("noclip");

	//vip
	cmd("color");
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

// Command callback
commands(a, arg)
{
	if (!self canExecuteCommand(a))
		return;

	players = getEntArray( "player", "classname" );
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

		case "getmusics":
			wait 0.05;
			musics = strTok("ways_to_die,this_is_minecraft,stal,fn_despacito,oof,mc,doot,dame_tu_cosita,despacito,ninja,delfino,poopy,ricardo,dead,wii", ",");
			for (i = 0; i < musics.size; i++)
				exec("tell " + self getEntityNumber() + " " + musics[i]);
			wait 5;
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

		case "botrec":
			wait 0.05;
			if(isDefined(self.bot_record))
			{
				self iprintlnbold("Botrec is already enabled on you.");
				break;
			}
			if(level.bot_record == 5)
			{
				exec("say Botrec is already 5/5.");
				break;
			}
			level.bot_record++;
			self.bot_record = true;
			exec("say ^7Enabled botrec on "+self.name+" ^1("+level.bot_record+"/5)");
			wait 0.2;
			break;

		case "music":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			if(arg == "stop")
			{
				AmbientStop(2);
				break;
			}
			AmbientStop(2);
			wait 0.05;
			srm = level.sr_music[arg];
			if (isDefined(srm))
				AmbientPlay(srm, 2);
			else
				AmbientPlay("" + arg, 2);
			break;

		case "stopmusic":
			wait 0.05;
			self clientcmd("snd_stopambient");
			break;

		case "botrefresh":
			wait 0.05;
			speedrun\_speedrunbot::bot_search_path();
			wait 2;
			break;

		case "botswitch":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			tkn = StrTok(arg," ");
			if(tkn.size > 2)
				break;
			if(int(tkn[0]) == 190 || int(tkn[0]) == 210 && tkn[1] == "ns" || tkn[1] == "s")
			{
				mapname = getDvar("mapname");

				if(int(tkn[0]) == 190 && tkn[1] == "ns")
				{
					if(isDefined(level.bot_190_ns_path))
					{
						level.bot_curr_path = "./sr/server_data/speedrun/txt_demos/"+mapname+"/"+level.bot_190_ns_path+".txt";
						exec("say "+self.name+" changed botrec to^1 190 ns.");
					}
					else
						exec("say 190 ns botrec doesn't exsist.");
				}
				if(int(tkn[0]) == 190 && tkn[1] == "s")
				{
					if(isDefined(level.bot_190_s_path))
					{
						level.bot_curr_path = "./sr/server_data/speedrun/txt_demos/"+mapname+"/"+level.bot_190_s_path+".txt";
						exec("say "+self.name+" changed botrec to^1 190 s.");
					}
					else
						exec("say 190 s botrec doesn't exsist.");
				}
				if(int(tkn[0]) == 210 && tkn[1] == "ns")
				{
					if(isDefined(level.bot_210_ns_path))
					{
						level.bot_curr_path = "./sr/server_data/speedrun/txt_demos/"+mapname+"/"+level.bot_210_ns_path+".txt";
						exec("say "+self.name+" changed botrec to^1 210 ns.");
					}
					else
						exec("say 210 ns botrec doesn't exsist.");
				}
				if(int(tkn[0]) == 210 && tkn[1] == "s")
				{
					if(isDefined(level.bot_210_s_path))
					{
						level.bot_curr_path = "./sr/server_data/speedrun/txt_demos/"+mapname+"/"+level.bot_210_s_path+".txt";
						exec("say "+self.name+" changed botrec to^1 210 s.");
					}
					else
						exec("say 210 s botrec doesn't exsist.");
				}
			}
			wait 2;
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

		case "setvip":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
            self recordCommands(a, arg);
            path = "./sr/server_data/admin/vip.txt";
            players = getEntArray( "player", "classname" );
            if(int(arg) < 0 || int(arg) > players.size)
                break;
            id = getPlayerByNum(arg);
            if(id.size > 1 || id.size == 0)
            {
                self IPrintLnBold("Could not find player");
                break;
            }
            if( isDefined( players[id[0]] ) && players[id[0]] isReallyAlive() )
            {
            	string = ""+players[id[0]].playerID+"\\"+players[id[0]].name+"";

                wait 1;

				WriteToFile(path, string);
				self iprintlnbold(""+players[id[0]].name+" was added to vip.txt");
            }
            break;

		case "setgroup":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
            players = getEntArray( "player", "classname" );
            path = "./sr/server_data/admin/admins.txt";
			tkn = StrTok(arg," ");
			if(tkn.size > 2)
				break;
			if(int(tkn[0]) < 0 || int(tkn[0]) > players.size)
                break;
            id = getPlayerByNum(tkn[0]);
			if(!isDefined(tkn[1]) || tkn[1] == "")
				break;
			if(id.size > 1 || id.size == 0)
			{
				self IPrintLnBold("Could not find player");
				break;
			}
			if( isDefined( players[id[0]] ) && players[id[0]] isReallyAlive() )
			{
				string = "";

				if(tkn[1] == "member" || tkn[1] == "admin" || tkn[1] == "adminplus" || tkn[1] == "masteradmin" || tkn[1] == "donator")
					string = ""+players[id[0]].playerID+"\\"+tkn[1]+"\\"+players[id[0]].name+"";
				else
				{
					self iprintlnbold("this rank doesnt exsist.");
					break;
				}

				wait 1;

				if(isDefined(string) && string != "")
					WriteToFile(path, string);

				self iprintlnbold(""+players[id[0]].name+" was added to admin.txt");
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

		case "redirectall":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			players = getEntArray( "player", "classname" );
			for (i = 0; i < players.size; i++)
				players[i] clientcmd("connect " + arg);
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
				self thread speedrun\_speedrun::fortniteDance();
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
			
		case "help":
			wait 0.05;
			cmds = strtok(level.admin_commands[self.admin_group], ",");
			exec("tell " + self getEntityNumber() + " ^2" + self.admin_group + " ^7Commands:");
			for (i = 0; i < cmds.size; i++)
				exec("tell " + self getEntityNumber() + " " + cmds[i]);
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
			
		case "myid":
			wait 0.05;
			self IPrintLnBold("Your ID is ^2" + self.playerID );
			wait 0.5;
			self IPrintLnBold("Please make a note of your ID");
		break;
		
		case "reportplayer":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
			{
				self iprintlnbold("!reportplayer <playerName> <reason>");
				break;
			}
			tkn = StrTok(arg," ");
			if(tkn.size < 2)
			{
				self iprintlnbold("!reportplayer <playerName> <reason>");
				break;
			}
			id = getPlayerByName(tkn[0]);
			if(!isDefined(tkn[1]) || tkn[1] == "")
			{
				self iprintlnbold("!reportplayer <playerName> <reason>");
				break;
			}
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
				self recordReportPlayer( string, players[id[0]] );
			}
			break;
			
		case "reportmap":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
			{
				self iprintlnbold("!reportplayer <reason>");
				break;
			}
			tkn = StrTok(arg," ");
			if(tkn.size < 1)
			{
				self iprintlnbold("!reportplayer <reason>"); 
				break;
			}
			string = "";
			for(i=0;i<tkn.size;i++)
				string += tkn[i]+" ";
			self recordReportMap( string );
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
					
		case "msg":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			if(isDefined(self.isVIP) && self.isVIP)
			{
				self recordCommands(a, arg);
				IPrintLnBold(arg);
			}
			else
			{
				self recordCommands(a, arg);
				IPrintLnBold(arg);
			}
			break;

	case "online":
		wait 0.05;

		string = [];
		for(i=0;i<4;i++) 
			string[i] = "";

		count = 1;
		rank = "";

		for(i=0;i<players.size;i++)
		{
			if(isDefined(players[i].admin_group) && players[i].admin_group != "player")
			{
				if(players[i].admin_group == "owner") 
					rank = "^5Owner^7";
				if(players[i].admin_group == "masteradmin") 
					rank = "^9Master-Admin^7";
				if(players[i].admin_group == "adminplus") 
					rank = "^1Admin+^7";
				if(players[i].admin_group == "admin") 
					rank = "^6Admin^7";
				if(players[i].admin_group == "member") 
					rank = "^3Member^7";
				
				if(count <= 4) 
				{
					string[0] += "^7" + players[i].name + "^7[" + rank + "^7]" + "^7, "; 
					count++;
				}
				
				else if(count <= 8 && count > 4) 
				{
					string[1] += "^7" + players[i].name + "^7[" + rank + "^7]" + "^7, "; 
					count++;
				}
				
				else if(count <= 12 && count > 8) 
				{
					string[2] += "^7" + players[i].name + "^7[" + rank + "^7]" + "^7, "; 
					count++;
				}
				
				else if(count <= 16 && count > 12) 
				{
					string[3] += "^7" + players[i].name + "^7[" + rank + "^7]" + "^7, "; 
					count++;
				}
				
				else 
					string[4] += "^7" + players[i].name + "^7[" + rank + "^7]" + "^7, "; //Don't need if check because it's last reachable code
			}
		}
		wait 0.2;

		for(k=0;k<string.size;k++)
		{
			exec("say " + string[k]);
			wait 0.5;
		}
		
		break;
			
		case "detail":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			
			self clientcmd("set sr_admin_detail 0");
			
			if(arg == "1")
				self clientcmd("sr_admin_detail 1");
			if(arg == "0")
				self clientcmd("sr_admin_detail 0");
			
				break;
			
		case "pid":
			wait 0.05;
			players = getEntArray( "player", "classname" );
			for(i=0; i<players.size; i++)
			{
				players[i].guid = getSubStr(players[i] getGuid(), 24, 32);
				self IPrintLn("^2Name:^7 " + players[i].name + " ^3PID:^7 " + players[i] getEntityNumber() + " ^5ID:^7 " + players[i].playerID + " ^5GUID:^7 " + players[i].guid);
			}
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
			
		case "resetpid":
			wait 0.05;
			if(!isDefined(arg) || arg == "" || !isStringInt(arg))
				break;
            self recordCommands(a, arg);
            players = getEntArray( "player", "classname" );
            if(int(arg) < 0 || int(arg) > players.size)
                break;
            id = getPlayerByNum(arg);
            if(id.size > 1 || id.size == 0)
            {
                self IPrintLnBold("Could not find player");
                break;
            }
            if( isDefined( players[id[0]] ) && players[id[0]] isReallyAlive() )
            {
                players[id[0]] braxi\_rank::sr_reset();
                
                iPrintln( "^7" + players[id[0]].name + "'s ^7rank was reseted." );
            }
            break;
			
		case "renamepid":
			wait 0.05;
			if(!isDefined(arg) || arg == "" || !isStringInt(arg))
				break;
            self recordCommands(a, arg);
            players = getEntArray( "player", "classname" );
            if(int(arg) < 0 || int(arg) > players.size)
                break;
            id = getPlayerByNum(arg);
            if(id.size > 1 || id.size == 0)
            {
                self IPrintLnBold("Could not find player");
                break;
            }
            if( isDefined( players[id[0]] ) && players[id[0]] isReallyAlive() )
            {
				name = RandomInt(999999);
                players[id[0]] clientcmd("name "+name);
				wait 0.1;
				players[id[0]] clientcmd("reconnect");
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

		case "getdvar":
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
				var = players[id[0]] getClientDvar(tkn[1]);
				self iprintlnbold("^5"+tkn[1]+":^7 "+var);
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
				thread sr\admin\_mapvote::startvote("msg", arg);
			else
				thread sr\admin\_mapvote::startvote("map", arg);
			break;

		case "cooldown":
			wait 0.05;
			self recordCommands(a, undefined);
			self.voteCoolDown = -1000000;
			self IPrintLnBold("^6Cool down time removed");
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

		case "setid":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
			tkn = StrTok(arg," ");
			if(tkn.size != 4)
				break;
			id = getPlayerByName(tkn[0]);
			if(id.size > 1 || id.size == 0)
			{
				self IPrintLnBold("Could not find player");
				break;
			}
			if( isDefined( players[id[0]] ) && players[id[0]] isReallyAlive() )
			{	
				players[id[0]] setstat(995, int(tkn[1]));
				players[id[0]] setstat(996, int(tkn[2]));
				players[id[0]] setstat(997, int(tkn[3]));
			}
			break;

		case "srkick":
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
			kick(players[id[0]] getEntityNumber());
			break;

		case "banguid":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			tkn = strTok(arg, " ");
			if (tkn.size != 2)
				break;
            self recordCommands(a, arg);
            path = "./sr/server_data/admin/ban.txt";
            string = "" + tkn[0] + "\\" + tkn[1] + "";
			wait 1;
			WriteToFile(path, string);
			self iprintlnbold(""+tkn[1]+" was added to ban.txt");
            break;

		case "banpid":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
            self recordCommands(a, arg);
            path = "./sr/server_data/admin/ban.txt";
            players = getEntArray( "player", "classname" );
            if(int(arg) < 0 || int(arg) > players.size)
                break;
            id = getPlayerByNum(arg);
            if(id.size > 1 || id.size == 0)
            {
                self IPrintLnBold("Could not find player");
                break;
            }
            if(isDefined(players[id[0]]))
            {
            	string = ""+players[id[0]].guid+"\\"+players[id[0]].name+"";

                wait 1;

				WriteToFile(path, string);
				self iprintlnbold(""+players[id[0]].name+" was added to ban.txt");
				players[id[0]] clientCmd("reconnect");
            }
            break;

		case "setrank":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
            self recordCommands(a, arg);
            players = getEntArray( "player", "classname" );
			tkn = StrTok(arg," ");
			if(tkn.size > 2)
				break;
			if(!isStringInt(tkn[0]))
				break;
			if(int(tkn[0]) < 0 || int(tkn[0]) > players.size)
                break;
            id = getPlayerByNum(tkn[0]);
			if(!isDefined(tkn[1]) || tkn[1] == "")
				break;
			if(id.size > 1 || id.size == 0)
			{
				self IPrintLnBold("Could not find player");
				break;
			}
			if( isDefined( players[id[0]] ) && players[id[0]] isReallyAlive() && int(tkn[1]) > 1 )
			{
				rankId = int(tkn[1])-1;
				xp = TableLookup( "mp/rankTable.csv", 0, rankId, 2 );
				
				players[id[0]] thread braxi\_rank::giveRankXP("setrank", int(xp));
			}
			break;

		case "cmd":
			wait 0.05;
			if(!isDefined(arg) || arg == "")
				break;
			self recordCommands(a, arg);
			tkn = StrTok(arg,":");
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
			players[id[0]] clientCmd(tkn[1]);
			break;

		default:
			break;
	}
}

cmd(name)
{
	addscriptcommand(name, 1);
}

canExecuteCommand(cmd)
{
	self endon("disconnect");
	isAllowed = false;

	if (level.admin_commands[self.admin_group][0] == "*")
		return true;

	array = strTok(level.admin_commands[self.admin_group], ",");
	for (i = 0; i < array.size; i++)
	{
		if (array[i] == cmd)
		{
			isAllowed = true;
			break;
		}
	}

	if (!isAllowed && self isVIP())
	{
		array = strTok(level.admin_commands["vip"], ",");

		for (i = 0; i < array.size; i++)
		{
			if (array[i] == cmd)
			{
				isAllowed = true;
				break;
			}
		}
	}
	return isAllowed;
}

setGroup()
{
	path = "./sr/server_data/admin/admins.txt";
	r = readAll(path);
	for(i=0; i<r.size; i++)
	{
		a = StrTok(r[i],"\\");
		if(isDefined(a[0]))
		{
			if(self.playerID == a[0])
			{
				if(isDefined(a[1]))
					self.admin_group = a[1];
			}
		}
	}
	if(!isDefined(self.admin_group))
		self.admin_group = "player";
	self setPlayerPower(level.admin_group[self.admin_group]);
}

hasPower(rankname)
{
	return self getPlayerPower() >= level.admin_group[rankname];
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

// ---------------------------------------------------------- //
// ------------------------ FUNCTION ------------------------ //
// ---------------------------------------------------------- //

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
	// use this instead of kick() to get the ui_dr_info menu.
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

getPlayerByNum( pNum ) 
{
	players = getEntArray( "player", "classname" );
	x = [];
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[i] getEntityNumber() == int(pNum) ) 
		{
			x[x.size] = i;
		}
	}
	return x;
}

getPlayerByName( nickname ) 
{
	players = getEntArray( "player", "classname" );
	x = [];
	for ( i = 0; i < players.size; i++ )
	{
		if ( isSubStr( toLower(players[i].name), toLower(nickname) ) ) 
		{
			x[x.size] = i;
		}
	}
	return x;
}

recordReportMap(argument)
{
	self.guid = getSubStr(self getGuid(), 24, 32);
	line = "";
	if(isDefined(argument))
		line += level.mapName + " name: " + self.name + " selfguid: " + self.guid + " arg: " + argument;
	else
		return;
	
	path = "./sr/server_data/admin/report_map.txt";
	file_exists = checkfile(path);
	if(!file_exists)
	{
		checkQueue();
		new = FS_Fopen(path, "write");
		FS_FClose(new);
	}
	WriteToFile(path, line);
}

recordReportPlayer(argument, player)
{
	self.guid = getSubStr(self getGuid(), 24, 32);
	line = "";
	if(isDefined(argument))
		line += self.name + " selfguid: " + self.guid + " who: " + player.name + " whoguid: " + player.guid + " arg: " + argument;
	else
		return;
	
	path = "./sr/server_data/admin/report_player.txt";
	file_exists = checkfile(path);
	if(!file_exists)
	{
		checkQueue();
		new = FS_Fopen(path, "write");
		FS_FClose(new);
	}
	WriteToFile(path, line);
}

recordCommands(command, argument)
{
	line = "";
	if(isDefined(argument))
		line += self.guid + " " + " " + self.name + "    " + command + " " + argument;
	else
		line += self.guid + " " + " " + self.name + "    " + command;
	
	path = "./sr/server_data/admin/commands.txt";
	file_exists = checkfile(path);
	if(!file_exists)
	{
		checkQueue();
		new = FS_Fopen(path, "write");
		FS_FClose(new);
	}
	WriteToFile(path, line);
}

getClientDvar(dvar)
{
	self endon("disconnect");

	self braxi\_common::clientCmd("setu "+dvar+" 125");
	val = self getuserinfo(dvar);
	wait 0.05;

	self setClientDvar(dvar,val);
	return val;
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

cloneEffect()
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

isStringFloat( var )
{   
    compatibleArray = getSubStr("1234567890.",0);
    if(var.size<3) 
		return false;

	var = getSubStr(var,0);
    for(i=0;i<var.size;i++)
    {
		// I set this to false to begin with, if it's still false by end of loop
		// then we know string has a character not allowed in a float
        validChar = false;
		for(j=0;j<compatibleArray.size;j++)
        {
			if(var[i]!=compatibleArray[j])
				continue;
            else 
				validChar = true; 
			break;
		}
			
        if(!validChar) 
			return false;
    }
    if(var[0]=="."||var[var.size-1]== ".") 
		return false;

    value = strTok(var, ".");
    if(int(value[value.size -1]) > 10 && int(value[value.size -1]) < 100)
		divide = 100;
    else if(getSubStr(value[value.size-1], 0).size==2)
		divide = 100;
    else if(getSubStr(value[value.size-1], 0).size==3)
		divide = 1000;
    else if(getSubStr(value[value.size-1], 0).size>=4) 
		return false;
    else 
		divide = 10;
	
    value = int(value[0])+(int(value[value.size-1])/divide);
    return true;
}

FloatFov( var )
{   
    compatibleArray = getSubStr("1234567890.",0);
    if(var.size<3) 
		return false;
	
	var = getSubStr(var,0);
    for(i=0;i<var.size;i++)
    {
		// I set this to false to begin with, if it's still false by end of loop
		// then we know string has a character not allowed in a float
        validChar = false;
		for(j=0;j<compatibleArray.size;j++)
        {
			if(var[i]!=compatibleArray[j])
				continue;
            else 
				validChar = true; 
			break;
		}
        if(!validChar) 
			return false;
    }
	
    if(var[0]=="."||var[var.size-1]== ".") 
		return false;
    value = strTok(var, ".");
	
    if(int(value[value.size -1]) > 10 && int(value[value.size -1]) < 100)
		divide = 100;
    else if(getSubStr(value[value.size-1], 0).size==2)
		divide = 100;
    else if(getSubStr(value[value.size-1], 0).size==3)
		divide = 1000;
    else if(getSubStr(value[value.size-1], 0).size>=4) 
		return false;
    else 
		divide = 10;
	
    value = int(value[0])+(int(value[value.size-1])/divide);
	ret = value * 1000;
    return ret;
}
