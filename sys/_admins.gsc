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

command(cmd, arg)
{
	if (!self canExecuteCommand(cmd))
		return;
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
