#include sr\sys\_file;
#include sr\sys\_events;
#include sr\utils\_common;

initAdmins()
{
	level.files["commands"] = PATH_Mod("data/logs/commands.txt");
	level.files["whitelist"] = PATH_Mod("data/match/whitelist.txt");

	level.ids = [];
	level.accounts = [];
	level.bans = [];
	level.admin_role = "owner";
	level.admin_commands = [];
	level.whitelist = [];

	level.admin_roles = [];
	level.admin_roles["player"] = 1;
	level.admin_roles["trusted"] = 2;
	level.admin_roles["member"] = 10;
	level.admin_roles["admin"] = 30;
	level.admin_roles["adminplus"] = 50;
	level.admin_roles["masteradmin"] = 60;
	level.admin_roles["owner"] = 100;

	level.special_roles = [];
	level.special_roles["vip"] = 1;
	level.special_roles["vipplus"] = 2;
	level.special_roles["donator"] = 3;

	event("command", ::command);

	thread fetch();
}

fetch()
{
	critical_enter("mysql");

	request = SQL_Prepare("SELECT password, player, role, vip, tas FROM players WHERE password != 0");
	SQL_Execute(request);
	AsyncWait(request);
	accounts = SQL_FetchRowsDict(request);
	SQL_Free(request);

	request = SQL_Prepare("SELECT guid, player, steamId, ip FROM bans");
	SQL_Execute(request);
	AsyncWait(request);
	bans = SQL_FetchRowsDict(request);
	SQL_Free(request);

	critical_release("mysql");

	for (i = 0; i < accounts.size; i++)
	{
		account = spawnStruct();
		account.id = accounts[i]["player"];
		account.password = ToInt(accounts[i]["password"]);
		account.role = accounts[i]["role"];
		account.vip = accounts[i]["vip"];
		account.tas = accounts[i]["tas"];
		accounts[i] = [];

		level.ids[level.ids.size] = account.id;
		level.accounts[account.id] = account;
	}
	accounts = undefined;
	for (i = 0; i < bans.size; i++)
	{
		entry = spawnStruct();
		entry.id = bans[i]["player"];
		entry.guid = bans[i]["guid"];
		entry.steamId = bans[i]["steamId"];
		entry.ip = bans[i]["ip"];
		bans[i] = [];

		level.bans[level.bans.size] = entry;
	}
	bans = undefined;
	loadWhitelist();
	level setLoading("admins", false);
}

connection()
{
	self endon("connect");
	self endon("disconnect");

	if (!self isFirstConnection())
	{
		self.id = self getPersistence("id");
		self.admin_auth = self getPersistence("auth");
		self.admin_register = self getPersistence("register");
		self.admin_role = self getPersistence("role");
		self.admin_vip = self getPersistence("vip");
		self.admin_tas = self getPersistence("tas");
		return;
	}
	level loading("admins");
	account = self account();
	self banned();

	self.admin_auth = account.password == self getStat(2800);
	self.admin_register = true;
	self.admin_role = Ternary(self.admin_auth, account.role, "player");
	self.admin_vip = Ternary(self.admin_auth, account.vip, 0);
	self.admin_tas = account.tas;

	self setPersistence("id", self.id);
	self setPersistence("auth", self.admin_auth);
	self setPersistence("register", self.admin_register);
	self setPersistence("role", self.admin_role);
	self setPersistence("vip", self.admin_vip);
	self setPersistence("tas", self.admin_tas);

	self setClientDvar("sr_admin_role", self getRoleName());
	self setStat(2000, self.admin_vip);

	self welcome();
	self thread database();
}

createAccount()
{
	account = spawnStruct();
	account.id = self.id;
	account.password = ToInt(generateToken(9));
	account.role = "player";
	account.vip = 0;
	account.tas = 0;

	self setStat(2800, account.password);

	return account;
}

account()
{
 	if (self getStat(995) && self getStat(996) && self getStat(997))
    {
		self.new = false;
		self.id = fmt("%d%d%d", self getStat(995), self getStat(996), self getStat(997));

		account = level.accounts[self.id];
		if (!isDefined(account))
			account = self createAccount();

		if (account.password == 0)
		{
			account.password = ToInt(generateToken(9));
			self setStat(2800, account.password);
		}
		level.accounts[self.id] = account;
		return account;
    }
	id0 = 0;
	id1 = 0;
	id2 = 0;

	while (true)
	{
		id0 = randomIntRange(1, 255);
		id1 = randomIntRange(1, 255);
		id2 = randomIntRange(1, 255);

		self.new = true;
		self.id = fmt("%d%d%d", id0, id1, id2);

		if (!Contains(level.ids, self.id))
			break;
	}
	account = self createAccount();

	self setStat(995, id0);
	self setStat(996, id1);
	self setStat(997, id2);

	level.ids[level.ids.size] = account.id;
	level.accounts[self.id] = account;
	return account;
}

database()
{
	self waittill("spawned");

	if (!isDefined(self))
		return;

	account = level.accounts[self.id];
	name = self.name;
	ip = self getIP();

    critical_enter("mysql");

    request = SQL_Prepare("UPDATE players SET password = ?, name = ?, ip = ?, date = NOW() WHERE player = ?");
    SQL_BindParam(request, account.password, level.MYSQL_TYPE_STRING);
    SQL_BindParam(request, name, level.MYSQL_TYPE_STRING);
    SQL_BindParam(request, ip, level.MYSQL_TYPE_STRING);
    SQL_BindParam(request, account.id, level.MYSQL_TYPE_STRING);
    SQL_Execute(request);
    AsyncWait(request);
    affected = SQL_AffectedRows(request);
    SQL_Free(request);

    if (!affected)
    {
        request = SQL_Prepare("INSERT INTO players (password, player, name, role, ip, date) VALUES (?, ?, ?, ?, ?, NOW())");
        SQL_BindParam(request, account.password, level.MYSQL_TYPE_STRING);
        SQL_BindParam(request, account.id, level.MYSQL_TYPE_STRING);
        SQL_BindParam(request, name, level.MYSQL_TYPE_STRING);
        SQL_BindParam(request, account.role, level.MYSQL_TYPE_STRING);
        SQL_BindParam(request, ip, level.MYSQL_TYPE_STRING);
        SQL_Execute(request);
        AsyncWait(request);
        SQL_Free(request);
    }
	critical_release("mysql");
}

cmd(name, role, callback, description)
{
	level.admin_commands[name] = spawnStruct();
	level.admin_commands[name].name = name;
	level.admin_commands[name].role = role;
	level.admin_commands[name].callback = callback;
	level.admin_commands[name].description = description;

	addScriptCommand(name, 1);
}

command(name, arg)
{
	// CoD4x crash without delay in the callback
	wait 0.05;

	cmd = level.admin_commands[toLower(name)];
	args = strTok(IfUndef(arg, ""), " ");

	if (!self canExecuteCommand(cmd))
	{
		self pm("^1Access denied");
		return;
	}
	self.lastCommand = fmt("%s %s", name, arg);
	comPrintLn("%s: !%s", self.name, self.lastCommand);
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

getPlayerInfo()
{
	return fmt("%s ^3PID:^7 %d ^5ID:^7 %s ^2GUID:^7 %s ^6STEAM:^7 %s ^1IP:^7 %s",
		self.name,
		self.number,
		self.id,
		self.guid,
		self getSteamId(),
		self getIP()
	);
}

banned()
{
	if (!self isBanned())
		return;

	exec(fmt("sv_kick %d", self.number));
}

tas(player, tas)
{
	level.accounts[player.id].tas = tas;

	critical_enter("mysql");

	request = SQL_Prepare("UPDATE players SET tas = ? WHERE player = ?");
	SQL_BindParam(request, tas, level.MYSQL_TYPE_LONG);
	SQL_BindParam(request, player, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);
	SQL_Free(request);

	request = SQL_Prepare("UPDATE leaderboards SET tas = ? WHERE player = ?");
	SQL_BindParam(request, tas, level.MYSQL_TYPE_LONG);
	SQL_BindParam(request, player, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);
	SQL_Free(request);

	critical_release("mysql");
}

welcome()
{
	role = self getRoleName();
	geo = self getGeoLocation(2);

	if (self isTAS())
		role = fmt("^5[TAS] ^7%s", role);

	message(fmt("^2Welcome ^7%s ^7%s ^7from ^1%s", role, self.name, geo));
}

whitelist()
{
	if (level.dvar["whitelist"])
	{
		message("Whitelist ^1disabled");
		setDvar("sr_whitelist", "0");
		level.dvar["whitelist"] = false;
		return;
	}
	critical_enter("mysql");

	request = SQL_Prepare("SELECT DISTINCT ip FROM players WHERE ip != '' AND tas = 0");
	SQL_Execute(request);
	AsyncWait(request);

	ips = [];
	rows = SQL_FetchRowsDict(request);
	for (i = 0; i < rows.size; i++)
		ips[i] = rows[i]["ip"];

	SQL_Free(request);

	// Local
	ips[ips.size] = "0.0.0.0";
	ips[ips.size] = "127.0.0.1";
	ips[ips.size] = "217.182.173.180";

	// Gametracker
	ips[ips.size] = "108.61.78.149";
	ips[ips.size] = "149.28.43.230";
	ips[ips.size] = "45.77.96.90";
	ips[ips.size] = "155.138.163.54";
	ips[ips.size] = "45.77.200.250";

	file = FILE_Open(level.files["whitelist"], "w");
	for (i = 0; i < ips.size; i++)
		FILE_WriteLine(file, ips[i]);
	FILE_Close(file);

	message("Whitelist ^5enabled");
	setDvar("sr_whitelist", "1");
	level.dvar["whitelist"] = true;

	critical_release("mysql");
}

loadWhitelist()
{
	file = FILE_Open(level.files["whitelist"], "a+");
	level.whitelist = FILE_ReadLines(file);
	FILE_Close(file);
}

log()
{
	if (!isPlayer(self))
		return;

	line = fmt("%s %s: %s", self.id, self.name, self.lastCommand);
	file = FILE_Open(level.files["commands"], "a+");
	FILE_WriteLine(file, line);
	FILE_Close(file);
}

printAuthRequired()
{
	if (!self isRegister())
		self iPrintLnBold("You need to ^5create an account ^7using the ^5!register ^7command");
	else if (!self isAuth())
		self iPrintLnBold("You need to ^5log in ^7using the ^5!login ^7command");
}

printLinkRequired()
{
	if (!self isAuth())
		self iPrintLnBold("You need to ^5contact an admin ^7to link this account");
}

isAuth()
{
	return self.admin_auth;
}

isRegister()
{
	return self.admin_register;
}

isRole(name)
{
	return level.admin_roles[self.admin_role] >= level.admin_roles[name];
}

isVIP()
{
	return self.admin_vip;
}

isTAS()
{
	return self.admin_tas;
}

isBanned()
{
	if (level.dvar["whitelist"] && !Contains(level.whitelist, self getIP()))
		return true;

	for (i = 0; i < level.bans.size; i++)
	{
		entry = level.bans[i];

		if (entry.id.size && entry.id == self.id)
			return true;
		if (entry.guid.size && entry.guid == self.guid)
			return true;
		if (entry.steamId.size && entry.steamId == self getSteamId())
			return true;
		if (entry.ip.size && entry.ip == self getIP())
			return true;
	}
	return false;
}
