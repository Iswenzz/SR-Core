#include sr\sys\_file;
#include sr\utils\_common;

initAdmins()
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

cmd(group, name, callback)
{
	level.admin_commands[name] = spawnStruct();
	level.admin_commands[name].name = name;
	level.admin_commands[name].group = group;
	level.admin_commands[name].callback = callback;

	addScriptCommand(name, 1);
}

command(name, arg)
{
	cmd = level.admin_commands[name];
	args = strTok(IfUndef(arg, ""), " ");

	if (!self canExecuteCommand(cmd))
		return;

	self thread [[cmd.callback]](args);
}

canExecuteCommand(cmd)
{
	if (isDefined(level.admin_group[cmd.group]))
		return self.admin_group >= level.admin_group[cmd.group];
	else if (isDefined(level.special_group[cmd.group]))
		return self isVIP() >= level.special_group[cmd.group];
	return false;
}

getGroupString()
{
	group = Ternary(!self.isBot, "^7Player", "^8Speedrun Bot");
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

isVIP()
{
	return true;
}

isBanned()
{
	return false;
}

banned()
{
	self setClientDvar("ui_dr_info", "^4You have been banned.");
	self setClientDvar("ui_dr_info2", "^5More info at https://discord.gg/76aHfGF");

	// Use this instead of kick() to get the ui_dr_info menu
	exec("kick " + self getEntityNumber() + " banned.");
}

log()
{
	line = fmt("%s %s\t%s", self.guid, self.name, self.lastCommand);

	file = FILE_OpenMod("sr/data/admin/commands.txt");
	FILE_WriteLine(file, line);
	FILE_Close(file);
}

message(msg)
{
	exec(fmt("say %s", msg));
}

pm(msg)
{
	exec(fmt("tell %d %s", self getEntityNumber(), msg));
}
