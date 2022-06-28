#include sr\sys\_file;
#include sr\sys\_events;
#include sr\utils\_common;

initAdmins()
{
	precache();

	// Roles
	level.admin_roles 					= [];
	level.admin_roles["player"] 		= 1;
	level.admin_roles["member"] 		= 10;
	level.admin_roles["admin"] 			= 30;
	level.admin_roles["adminplus"] 		= 50;
	level.admin_roles["masteradmin"] 	= 60;
	level.admin_roles["owner"] 			= 100;

	// Special
	level.special_roles["vip"] 			= 1;
	level.special_roles["donator"] 		= 2;

	// Commands
	level.admin_commands				= [];

	event("command", ::command);
	event("connect", ::banned);
	event("connect", ::fetch);
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

	precacheStatusIcon("vip_status");
	precacheShader("vip_status");
	precacheShader("vip_gold");

	precacheStatusIcon("hud_status_connecting");
	precacheStatusIcon("hud_status_dead");
	precacheHeadIcon("headicon_admin");

	precacheShellShock("flashbang");
	precacheShellShock("death");
	precacheShellShock("concussion_grenade_mp");
	precacheShellShock("damage_mp");
	precacheShellShock("frag_grenade_mp");

	precacheMenu("clientcmd");
}

fetch()
{
	mutex_acquire("mysql");

	SQL_Prepare("SELECT role, vip FROM admins WHERE player = ?");
	SQL_BindParam(self.id, level.MYSQL_TYPE_STRING);
	SQL_BindResult(level.MYSQL_TYPE_STRING, 20);
	SQL_BindResult(level.MYSQL_TYPE_LONG);
	SQL_Execute();

	if (SQL_NumRows())
	{
		row = SQL_FetchRowDict();
		self.admin_role = row["role"];
		self.admin_vip = row["vip"];
	}
	else
	{
		self.admin_role = "player";
		self.admin_vip = 0;
	}
	mutex_release("mysql");
}

cmd(role, name, callback)
{
	level.admin_commands[name] = spawnStruct();
	level.admin_commands[name].name = name;
	level.admin_commands[name].role = role;
	level.admin_commands[name].callback = callback;

	addScriptCommand(name, 1);
}

command(name, arg)
{
	wait 0.05; // CoD4x crash without delay in the callback ?

	cmd = level.admin_commands[name];
	args = strTok(IfUndef(arg, ""), " ");

	if (!self canExecuteCommand(cmd))
		return;

	self.lastCommand = fmt("%s %s", name, arg);
	self thread [[cmd.callback]](args);
}

canExecuteCommand(cmd, index)
{
	if (isDefined(level.admin_roles[cmd.role]))
		return self isRole(cmd.role);
	else if (isDefined(level.special_roles[cmd.role]))
		return self isVIP() >= level.special_roles[cmd.role];
	return false;
}

isRole(name)
{
	return level.admin_roles[self.admin_role] >= level.admin_roles[name];
}

getRoleName()
{
	role = Ternary(!self.isBot, "^7Player", "^8Speedrun Bot");
	switch (self.admin_role)
	{
		case "owner":
			role = "^5Owner";
			break;
		case "masteradmin":
			role = "^9Master Admin";
			break;
		case "adminplus":
			role = "^1Admin+";
			break;
		case "admin":
			role = "^6Admin";
			break;
		case "member":
			role = "^3Member";
			break;
	}
	return role;
}

isVIP()
{
	return self.admin_vip;
}

banned()
{
	self.guid = getSubStr(self getGuid(), 24, 32);

	mutex_acquire("mysql");

	SQL_Prepare("SELECT 1 FROM bans WHERE guid = ? OR player = ? OR steamId = ? OR ip = ?");
	SQL_BindParam(self.guid, level.MYSQL_TYPE_STRING);
	SQL_BindParam(self.id, level.MYSQL_TYPE_STRING);
	SQL_BindParam(self getSteamID(), level.MYSQL_TYPE_STRING);
	SQL_BindParam(self getIP(), level.MYSQL_TYPE_STRING);
	SQL_Execute();
	isBanned = SQL_NumRows();

	mutex_release("mysql");

	if (!isBanned)
		return;

	self setClientDvar("ui_dr_info", "^4You have been banned.");
	self setClientDvar("ui_dr_info2", "^5More info at https://discord.gg/76aHfGF");

	// Use this instead of kick() to get the ui_dr_info menu
	exec(fmt("kick %d banned.", self getEntityNumber()));
}

log()
{
	line = fmt("%s %s\t%s", self.guid, self.name, self.lastCommand);

	file = FILE_OpenMod("sr/data/admin/commands.txt", "a+");
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
