#include sr\sys\_file;
#include sr\sys\_events;
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

	level.admin_role = "owner";

	level.admin_roles["player"] 		= 1;
	level.admin_roles["trusted"] 		= 2;
	level.admin_roles["member"] 		= 10;
	level.admin_roles["admin"] 			= 30;
	level.admin_roles["adminplus"] 		= 50;
	level.admin_roles["masteradmin"] 	= 60;
	level.admin_roles["owner"] 			= 100;

	level.special_roles["vip"] 			= 1;
	level.special_roles["vip_plus"] 	= 2;
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
	critical_enter("mysql");

	request = SQL_Prepare("SELECT player, role, vip FROM admins");
	SQL_BindResult(request, level.MYSQL_TYPE_STRING, 36);
	SQL_BindResult(request, level.MYSQL_TYPE_STRING, 20);
	SQL_BindResult(request, level.MYSQL_TYPE_LONG);
	SQL_Execute(request);
	AsyncWait(request);

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
	SQL_BindResult(request, level.MYSQL_TYPE_STRING, 8);
	SQL_BindResult(request, level.MYSQL_TYPE_STRING, 36);
	SQL_BindResult(request, level.MYSQL_TYPE_STRING, 50);
	SQL_BindResult(request, level.MYSQL_TYPE_STRING, 15);
	SQL_Execute(request);
	AsyncWait(request);

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

	critical_release("mysql");

	level setLoading("admins", false);
}

connection()
{
	self endon("connect");
	self endon("disconnect");

	if (!self isFirstConnection())
	{
		self.admin_role = self getPersistence("admin");
		self.admin_vip = self getPersistence("vip");
		return;
	}
	level loading("admins");

	self banned();
	self.admin_role = IfUndef(level.admins[self.id], "player");
	self setClientDvar("sr_admin_role", self getRoleName());
	self setPersistence("admin", self.admin_role);

	self.admin_vip = IfUndef(level.vips[self.id], 0);
	self setStat(2000, self.admin_vip);
	self setPersistence("vip", self.admin_vip);

	self welcome();
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
	// CoD4x crash without delay in the callback
	wait 0.05;

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
	level loading("admins");
	return level.admin_roles[self.admin_role] >= level.admin_roles[name];
}

getRoleName()
{
	switch (self.admin_role)
	{
		case "owner":
			return "^5Owner";
		case "masteradmin":
			return "^9Master Admin";
		case "adminplus":
			return "^1Admin+";
		case "admin":
			return "^6Admin";
		case "member":
			return "^3Member";
		case "trusted":
			return "^8Trusted";
	}
	return Ternary(!self isBot(), "^7Player", "^8Bot");
}

isVIP()
{
	level loading("admins");
	return self.admin_vip;
}

getPlayerInfo()
{
	return fmt("%s ^3PID:^7 %d ^5ID:^7 %s ^2GUID:^7 %s ^6STEAM:^7 %s ^1IP:^7 %s",
		self.name,
		self getEntityNumber(),
		self.id,
		self.guid,
		self getSteamId(),
		self getIP()
	);
}

isBanned()
{
	for (i = 0; i < level.bans.size; i++)
	{
		entry = level.bans[i];

		if (entry[0].size > 1 && entry[0] == self.guid)
			return true;
		if (entry[1].size > 1 && entry[1] == self.id)
			return true;
		if (entry[2].size > 1 && entry[2] == self getSteamId())
			return true;
		if (entry[3].size > 1 && entry[3] == self getIP())
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
	exec(fmt("kick %d banned", self getEntityNumber()));
}

welcome()
{
	role = self sr\sys\_admins::getRoleName();
	geo = self getGeoLocation(2);

	message(fmt("^2Welcome ^7%s ^7%s ^7from ^1%s", role, self.name, geo));
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
