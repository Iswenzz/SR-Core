#include sr\sys\_file;
#include sr\sys\_events;
#include sr\sys\_mysql;
#include sr\utils\_common;

initAdmins()
{
	level.files["commands"] = PATH_Mod("sr/data/admin/commands.txt");

	precache();

	level.admins = [];
	level.vips = [];
	level.bans = [];
	level.admin_commands = [];
	level.admin_roles = [];
	level.special_roles = [];

	level.admin_roles["player"] 		= 1;
	level.admin_roles["trusted"] 		= 2;
	level.admin_roles["member"] 		= 10;
	level.admin_roles["admin"] 			= 30;
	level.admin_roles["adminplus"] 		= 50;
	level.admin_roles["masteradmin"] 	= 60;
	level.admin_roles["owner"] 			= 100;

	level.special_roles["vip"] 			= 1;
	level.special_roles["donator"] 		= 3;

	event("command", ::command);
	event("connect", ::connection);

	thread fetch();
}

precache()
{
	precacheModel("axis");
	precacheModel("chicken");
	precacheModel("bc_militarytent_draped");
	precacheModel("ch_roadrock_06");
	precacheModel("ch_russian_table");
	precacheModel("prop_flag_russian");
	precacheModel("prop_flag_neutral");

	precacheStatusIcon("vip_status");
	precacheShader("vip_status");
	precacheShader("vip_gold");

	precacheStatusIcon("hud_status_connecting");
	precacheStatusIcon("hud_status_dead");
	precacheHeadIcon("headicon_vip");

	precacheShellShock("default");
	precacheShellShock("flashbang");
	precacheShellShock("concussion_grenade_mp");
	precacheShellShock("damage_mp");
	precacheShellShock("frag_grenade_mp");
	precacheShellShock("radiation_high");

	precacheMenu("clientcmd");
}

fetch()
{
	mutex_acquire("mysql");

	request = SQL_Prepare("SELECT player, role, vip FROM admins");
	SQL_BindResult(request, level.MYSQL_TYPE_STRING, 36);
	SQL_BindResult(request, level.MYSQL_TYPE_STRING, 20);
	SQL_BindResult(request, level.MYSQL_TYPE_LONG);
	SQL_Execute(request);
	SQL_Wait(request);

	rows = SQL_FetchRowsDict(request);
	for (i = 0; i < rows.size; i++)
	{
		row = rows[i];
		player = row["player"];

		level.admins[player] = row["role"];
		level.vips[player] = row["vip"];
	}
	SQL_Free(request);

	request = SQL_Prepare("SELECT guid, player, steamId, ip FROM bans");
	SQL_BindResult(request, level.MYSQL_TYPE_STRING);
	SQL_BindResult(request, level.MYSQL_TYPE_STRING);
	SQL_BindResult(request, level.MYSQL_TYPE_STRING);
	SQL_BindResult(request, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	SQL_Wait(request);

	rows = SQL_FetchRowsDict(request);
	for (i = 0; i < rows.size; i++)
	{
		row = rows[i];

		entry = [];
		entry[entry.size] = row["guid"];
		entry[entry.size] = row["player"];
		entry[entry.size] = row["steamId"];
		entry[entry.size] = row["ip"];

		level.bans[level.bans.size] = entry;
	}
	SQL_Free(request);

	mutex_release("mysql");
}

connection()
{
	self endon("disconnect");

	self banned();

	self.admin_role = IfUndef(level.admins[self.id], "player");
	self setClientDvar("sr_admin_role", self getRoleName());

	self.admin_vip = IfUndef(level.vips[self.id], 0);
	self setStat(2000, self.admin_vip);
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
	if (!isDefined(cmd))
		return false;
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
		case "trusted":
			role = "^8Trusted";
			break;
	}
	return role;
}

isVIP()
{
	return self.admin_vip;
}

isBanned()
{
	self.guid = getSubStr(self getGuid(), 24, 32);

	for (i = 0; i < level.bans.size; i++)
	{
		entry = level.bans[i];

		if (entry[0] == self.guid)
			return true;
		if (entry[1] == self.id)
			return true;
		if (entry[2] == self getSteamId())
			return true;
		if (entry[3] == self getIP())
			return true;
	}
	return false;
}

banned()
{
	if (!self isBanned())
		return;

	self setClientDvar("ui_sr_info", "^5You have been banned.");
	self setClientDvar("ui_sr_info2", "More info at https://discord.gg/76aHfGF");

	// Use this instead of kick() to get the ui_sr_info menu
	exec(fmt("kick %d banned.", self getEntityNumber()));
}

log()
{
	if (!isPlayer(self))
		return;

	line = fmt("%s %s\t%s", self.guid, self.name, self.lastCommand);

	file = FILE_Open(level.files["commands"], "a+");
	FILE_WriteLine(file, line);
	FILE_Close(file);
}

printBold(msg)
{
	if (!isPlayer(self))
	{
		sysPrintLn(msg);
		return;
	}
	self iPrintLnBold(msg);
}

printLine(msg)
{
	if (!isPlayer(self))
	{
		sysPrintLn(msg);
		return;
	}
	self iPrintLn(msg);
}

message(msg)
{
	exec(fmt("say %s", msg));
}

pm(msg)
{
	if (isPlayer(self))
		exec(fmt("tell %d %s", self getEntityNumber(), msg));
}
