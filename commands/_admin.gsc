#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	cmd("ban",            "masteradmin",  ::cmd_Ban,             "Ban a player from the server");
	cmd("clientcmd",      "owner",        ::cmd_ClientCommand,   "Execute a command on a client");
	cmd("cmd",            "owner",        ::cmd_Command,         "Execute a server command");
	cmd("confirm",        "player",       ::cmd_Confirm,         "Confirm a pending action");
	cmd("end",            "owner",        ::cmd_End,             "End the current game");
	cmd("event_next",     "owner",        ::cmd_EventNext,       "Skip to the next event");
	cmd("event_round",    "owner",        ::cmd_EventRound,      "Start an event for the current round");
	cmd("event_stop",     "owner",        ::cmd_EventStop,       "Stop the current event");
	cmd("event",          "owner",        ::cmd_Event,           "Start a server event");
	cmd("getdvar",        "owner",        ::cmd_GetDvar,         "Get the value of a dvar");
	cmd("givexp",         "owner",        ::cmd_GiveXp,          "Give XP to a player");
	cmd("gpt",            "adminplus",    ::cmd_GPT,             "Ask a question to the AI clanker");
	cmd("help",           "player",       ::cmd_Help,            "Display available commands and usage");
	cmd("id",             "owner",        ::cmd_ID,              "Set player ID");
	cmd("kick",           "admin",        ::cmd_Kick,            "Kick a player from the server");
	cmd("link",           "masteradmin",  ::cmd_Link,            "Link a player account");
	cmd("maprestart",     "owner",        ::cmd_MapRestart,      "Restart the map");
	cmd("module",         "masteradmin",  ::cmd_Module,          "Request a player loaded DLLs");
	cmd("msg",            "member",       ::cmd_Msg,             "Display a message");
	cmd("nextmap",        "owner",        ::cmd_NextMap,         "Switch to the next map in rotation");
	cmd("notification",   "owner",        ::cmd_Notification,    "Send a server notification");
	cmd("online",         "member",       ::cmd_Online,          "Display online admins");
	cmd("owner",          "owner",        ::cmd_Owner,           "Owner overlay");
	cmd("pid",            "admin",        ::cmd_PID,             "List player IDs");
	cmd("pm",             "player",       ::cmd_PM,              "Send a private message to a player");
	cmd("print",          "member",       ::cmd_Print,           "Print a message to the console");
	cmd("rank",           "owner",        ::cmd_Rank,            "Set player rank and prestige");
	cmd("rcon",           "owner",        ::cmd_Rcon,            "Execute a remote console command");
	cmd("reconnect",      "masteradmin",  ::cmd_Reconnect,       "Reconnect a player");
	cmd("redirect_all",   "owner",        ::cmd_RedirectAll,     "Redirect all players to another server");
	cmd("rename",         "admin",        ::cmd_Rename,          "Rename a player");
	cmd("reset_rank",     "masteradmin",  ::cmd_ResetRank,       "Reset player rank to default");
	cmd("reset_settings", "player",       ::cmd_ResetSettings,   "Reset player settings");
	cmd("restart",        "owner",        ::cmd_Restart,         "Fast restart virtual machine");
	cmd("role",           "owner",        ::cmd_Role,            "Set a player admin role");
	cmd("screenshot",     "masteradmin",  ::cmd_Screenshot,      "Request a player game screenshot");
	cmd("setdvar",        "owner",        ::cmd_SetDvar,         "Set dvar value");
	cmd("setmap",         "owner",        ::cmd_Map,             "Change map");
	cmd("tas_id",         "masteradmin",  ::cmd_RegisterTASID,   "Register TAS player from ID");
	cmd("tas_player",     "masteradmin",  ::cmd_RegisterTAS,     "Register TAS player");
	cmd("tas",            "player",       ::cmd_TAS,             "Register as a Tool Assisted Speedrun user");
	cmd("timeplayed",     "member",       ::cmd_TimePlayed,      "Time played on the server");
	cmd("vip",            "owner",        ::cmd_VIP,             "Set VIP");
	cmd("whitelist",      "adminplus",    ::cmd_Whitelist,       "Turn on network IP whitelist");
}

cmd_Restart(args)
{
	levelRestart(true);
}

cmd_MapRestart(args)
{
	setDvar("sv_maprotationcurrent", fmt("gametype %s map %s", getDvar("g_gametype"), level.map));
	levelExit(false);
}

cmd_Map(args)
{
	if (args.size < 1)
		return self pm("Usage: !setmap <name>");

	map = args[0];
	setDvar("sv_maprotationcurrent", fmt("gametype %s map %s", getDvar("g_gametype"), map));
	levelExit(false);
}

cmd_Event(args)
{
	if (!isDefined(level.eventMap))
		return self pm("^1This map is not an event map");

	if (sr\core\_event::isEvent())
		return self pm("^1Event already started");

	// self command("bots", "9");
	sr\core\_event::start();
}

cmd_EventNext(args)
{
	level.eventGame++;
	level notify("event_game_end");
	level notify("event_round_end");
}

cmd_EventRound(args)
{
	level notify("event_round_end");
}

cmd_EventStop(args)
{
	level.eventGame = level.eventGames;
	level notify("event_game_end");
	level notify("event_round_end");
}

cmd_End(args)
{
	eventEnd();
}

cmd_NextMap(args)
{
	maps = level.randomizedMaps;
	map = maps[randomInt(maps.size)];
	setDvar("sv_maprotationcurrent", fmt("gametype %s map %s", getDvar("g_gametype"), map));
	levelExit(false);
}

cmd_PM(args)
{
	if (args.size < 2)
		return self pm("Usage: !pm <playerName> <message>");

	player = getPlayerByName(args[0]);
	if (!isDefined(player))
		return pm("Could not find player");

	msg = StrJoin(Range(args, 1, args.size), " ");

	exec(fmt("tell %d ^2To %s:^7 %s", self.number, player.name, msg));
	exec(fmt("tell %d ^2%s:^7 %s", player.number, self.name, msg));
}

cmd_Command(args)
{
	if (args.size < 2)
		return self pm("Usage: !cmd <playerNum> <command>");

	player = getPlayerByNum(args[0]);
	cmd = args[1];
	cmdArgs = undefined;
	if (args.size > 2)
		cmdArgs = StrJoin(Range(args, 2, args.size), " ");

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player thread command(cmd, cmdArgs);
}

cmd_ClientCommand(args)
{
	if (args.size < 2)
		return self pm("Usage: !clientcmd <playerNum> <command>");

	player = getPlayerByNum(args[0]);
	cmd = StrJoin(Range(args, 1, args.size), " ");

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player clientCmd(cmd);
}

cmd_Confirm(args)
{
	self notify("confirmed");
}

cmd_GPT(args)
{
	if (args.size < 1)
		return self pm("Usage: !gpt <message>");

	message = StrJoin(args, " ");
	self sr\sys\_gpt::completions(message);
}

cmd_GiveXp(args)
{
	if (args.size < 2)
		return self pm("Usage: !givexp <playerName> <xp>");

	player = getPlayerByName(args[0]);
	xp = ToInt(args[1]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player sr\core\_rank::giveRankXP("", xp);
}

cmd_SetDvar(args)
{
	if (args.size < 3)
		return self pm("Usage: !getdvar <playerName> <dvar> <value>");

	player = getPlayerByName(args[0]);
	dvar = args[1];
	value = args[2];

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player setClientDvar(dvar, value);
	self pm(fmt("%s: %s", dvar, value));
}

cmd_Screenshot(args)
{
	self log();
	if (args.size < 1)
		return self pm("Usage: !screenshot <playerId>");

	player = getPlayerByNum(args[0]);
	if (!isDefined(player))
		return pm("Could not find player");

	exec(fmt("getss %d %s_%d", player.number, player.id, randomInt(999999)));
	self pm("^5Screenshot request sent");
}

cmd_GetDvar(args)
{
	if (args.size < 2)
		return self pm("Usage: !getdvar <playerName> <dvar>");

	player = getPlayerByName(args[0]);
	dvar = args[1];

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	value = player getClientDvar(dvar);
	self pm(fmt("%s: %s", dvar, value));
}

cmd_Help(args)
{
	valids = [];
	keys = Sort(getArrayKeys(level.admin_commands));
	for (i = 0; i < keys.size; i++)
	{
		if (!self canExecuteCommand(level.admin_commands[keys[i]]))
			continue;
		valids[valids.size] = keys[i];
	}
	self pm(fmt("%s ^7commands:", self getRoleName()));

	for (i = 0; i < valids.size; i++)
	{
		cmd = level.admin_commands[valids[i]];
		self pm(fmt("!%s %s", cmd.name, cmd.description));
		wait 0.05;
	}
}

cmd_Msg(args)
{
	if (args.size < 1)
		return self pm("Usage: !msg <message>");

	printBold(StrJoin(args, " "));
}

cmd_Module(args)
{
	self log();
	if (args.size < 1)
		return self pm("Usage: !module <playerId>");

	player = getPlayerByNum(args[0]);
	if (!isDefined(player))
		return pm("Could not find player");

	exec(fmt("getmodules %d %s_%d", player.number, player.id, randomInt(999999)));
	self pm("^5Module request sent");
}

cmd_Notification(args)
{
	if (args.size < 1)
		return self pm("Usage: !notification <message>");

	level sr\huds\_notifications::show(StrJoin(args, " "));
}

cmd_Online(args)
{
	onlines = [];
	index = 0;

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		role = players[i] getRoleName();
		if (players[i].admin_role != "player")
			onlines[onlines.size] = fmt("%s^7[%s^7]", players[i].name, players[i] getRoleName());
	}
	strings = strTokByPixLen(StrJoin(onlines, ", "), 500);

	message("Online:");
	for (i = 0; i < strings.size; i++)
		message(strings[i]);
}

cmd_Owner(args)
{
	self giveWeapon("airstrike_mp");
	wait 0.05;
	self switchToWeapon("airstrike_mp");
}

cmd_PID(args)
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		self printLine(players[i] getPlayerInfo());
}

cmd_Print(args)
{
	if (args.size < 1)
		return self pm("Usage: !print <message>");

	printLine(StrJoin(args, " "));
}

cmd_Rcon(args)
{
	if (args.size < 1)
		return self pm("Usage: !rcon <command>");

	player = getPlayerByNum(args[0]);
	cmd = StrJoin(args, " ");

	self log();
	exec(fmt("rcon %s", cmd));
}

cmd_Rank(args)
{
	if (args.size < 2)
		return self pm("Usage: !rank <playerName> <rank> <?prestige>");

	player = getPlayerByName(args[0]);
	rank = ToInt(args[1]) - 1;

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	prestige = ToInt(IfUndef(args[2], player.pers["prestige"]));

	player.pers["rankxp"] = sr\core\_rank::getRankInfoMinXP(rank);
	player.pers["rank"] = rank;
	player.pers["prestige"] = prestige;

	player sr\core\_rank::saveRank();
	player reconnect();
}

cmd_ResetRank(args)
{
	if (args.size < 1)
		return self pm("Usage: !reset_rank <playerName>");

	player = getPlayerByName(args[0]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player sr\core\_rank::reset();
	player reconnect();
}

cmd_ResetSettings(args)
{
	self sr\core\_settings::reset();
	self pm("^2Settings reset");
}

cmd_RedirectAll(args)
{
	if (args.size < 1)
		return self pm("Usage: !redirect_all <ip>");

	ip = args[0];
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] clientCmd(fmt("connect %s", ip));
}

cmd_Reconnect(args)
{
	if (args.size < 1)
		return self pm("Usage: !reconnect <playerNum>");

	player = getPlayerByNum(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	player reconnect();
}

cmd_Rename(args)
{
	if (args.size < 2)
		return self pm("Usage: !rename <playerNum> <newName>");

	player = getPlayerByNum(args[0]);
	newName = StrJoin(Range(args, 1, args.size), " ");

	if (!isDefined(player))
		return pm("Could not find player");

	player clientCmd(fmt("name %s", IfUndef(newName, ToString(randomInt(999999)))));
	wait 0.1;
	player reconnect();
}

cmd_TimePlayed(args)
{
	if (args.size < 1)
		return self pm("Usage: !timeplayed <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	mins = player getStat(2629);
	hours = mins / 60;
	pm(fmt("%s played: %d", player.name, int(hours) + "h"));
}

cmd_Kick(args)
{
	if (args.size < 1)
		return self pm("Usage: !kick <playerNum>");

	player = getPlayerByNum(args[0]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	kick(player.number);
}

cmd_Role(args)
{
	if (args.size < 2)
		return self pm("Usage: !role <playerNum> <role>");

	player = getPlayerByNum(args[0]);
	role = args[1];

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	critical_enter("mysql");

	request = SQL_Prepare("UPDATE players SET role = ? WHERE player = ?");
	SQL_BindParam(request, role, level.MYSQL_TYPE_STRING);
	SQL_BindParam(request, player.id, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);
	SQL_Free(request);

	critical_release("mysql");

	level.accounts[player.id].role = role;
	player.admin_role = role;

	message(fmt("Promoted %s ^7to %s", player.name, player getRoleName()));
	player reconnect();
}

cmd_VIP(args)
{
	if (args.size < 1)
		return self pm("Usage: !vip <playerNum> <vip>");

	player = getPlayerByNum(args[0]);
	vip = IfUndef(ToInt(args[1]), 1);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	critical_enter("mysql");

	request = SQL_Prepare("UPDATE players SET vip = ? WHERE player = ?");
	SQL_BindParam(request, vip, level.MYSQL_TYPE_LONG);
	SQL_BindParam(request, player.id, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);
	SQL_Free(request);

	critical_release("mysql");

	level.accounts[player.id].vip = vip;
	player.admin_vip = vip;

	message(fmt("Promoted %s ^7to ^2VIP(%d)", player.name, vip));
	player reconnect();
}

cmd_TAS(args)
{
	name = self.name;
	id = self.id;

	if (self isTAS())
		return;

	self pm("You are about to register as a ^5TAS ^7user. This is an ^1irreversible action^7. To confirm that you agree, type ^2!confirm");

	response = self confirmation();
	if (!hasConfirmed(response))
		return;

	sr\sys\_admins::tas(id, true);

	player = getPlayerById(id);
	if (!isDefined(player))
		return;

	player reconnect();
}

cmd_RegisterTAS(args)
{
	if (args.size < 1)
		return self pm("Usage: !tas_player <playerNum>");

	player = getPlayerByNum(args[0]);
	if (!isDefined(player))
		return pm("Could not find player");

	name = player.name;
	id = player.id;
	tas = player isTAS();

	self log();
	if (!tas)
		self pm(fmt("You are about to register %s a ^5TAS ^7user. To confirm that you agree, please type ^2!confirm", name));
	else
		self pm(fmt("You are about to unregister %s from ^5TAS ^7user. To confirm that you agree, please type ^2!confirm", name));

	response = self confirmation();
	if (!hasConfirmed(response))
		return;

	sr\sys\_admins::tas(id, !tas);

	player = getPlayerById(id);
	if (!isDefined(player))
		return;

	player reconnect();
}

cmd_RegisterTASID(args)
{
	if (args.size < 2)
		return self pm("Usage: !tas_id <playerId> <state>");

	id = args[0];
	state = ToInt(args[1]);

	self log();
	if (state)
		self pm(fmt("You are about to register %s a ^5TAS ^7user. To confirm that you agree, please type ^2!confirm", id));
	else
		self pm(fmt("You are about to unregister %s from ^5TAS ^7user. To confirm that you agree, please type ^2!confirm", id));

	response = self confirmation();
	if (!hasConfirmed(response))
		return;

	sr\sys\_admins::tas(id, state);

	player = getPlayerById(id);
	if (!isDefined(player))
		return;

	player reconnect();
}

cmd_ID(args)
{
	if (args.size < 4)
		return self pm("Usage: !id <playerNum> <stat 1> <stat 2> <stat 3>");

	player = getPlayerByNum(args[0]);
	id0 = ToInt(args[1]);
	id1 = ToInt(args[2]);
	id2 = ToInt(args[3]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	id = fmt("%d%d%d", id0, id1, id2);
	account = level.accounts[id];

	player setStat(995, id0);
	player setStat(996, id1);
	player setStat(997, id2);

	if (isDefined(account))
		player setStat(2800, account.password);

	player reconnect();
}

cmd_Ban(args)
{
	self log();
	if (args.size < 2)
		return self pm("Usage: !ban <name> <guid> <?id> <?steamId> <?ip>");

	name = args[0];
	guid = args[1];
	id = IfUndef(args[2], "");
	steamId = IfUndef(args[3], "");
	ip = IfUndef(args[4], "");

	critical_enter("mysql");

	request = SQL_Prepare("INSERT INTO bans (name, guid, player, steamId, ip) VALUES (?, ?, ?, ?, ?)");
	SQL_BindParam(request, name, level.MYSQL_TYPE_STRING);
	SQL_BindParam(request, guid, level.MYSQL_TYPE_STRING);
	SQL_BindParam(request, id, level.MYSQL_TYPE_STRING);
	SQL_BindParam(request, steamId, level.MYSQL_TYPE_STRING);
	SQL_BindParam(request, ip, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);
	SQL_Free(request);

	critical_release("mysql");
}

cmd_Whitelist(args)
{
	self log();
	if (!level.dvar["whitelist"])
		self pm("You are about to ^2enable ^7the whitelist. To confirm that you agree, please type ^2!confirm");
	else
		self pm("You are about to ^1disable ^7the whitelist. To confirm that you agree, please type ^2!confirm");

	response = self confirmation();
	if (!hasConfirmed(response))
		return;

	sr\sys\_admins::whitelist();
	wait 1;
	setDvar("sv_maprotationcurrent", fmt("gametype %s map %s", getDvar("g_gametype"), level.map));
	levelExit(false);
}

cmd_Link(args)
{
	if (args.size < 1)
		return self pm("Usage: !link <playerNum>");

	player = getPlayerByNum(args[0]);

	if (!isDefined(player))
		return self pm("^1Could not find player");

	self pm(fmt("You are about to link ^5%s ^7to account ^5%s^7.", player.name, player.id));
	wait 0.05;
	self pm("Make sure this is the right person, this will ^5grant them the password to this account. ^7Type ^2!confirm ^7to proceed");

	response = self confirmation();
	if (!hasConfirmed(response))
		return;

	password = ToInt(generateToken(9));
	account = level.accounts[player.id];
	account.password = password;
	level.accounts[player.id] = account;

	player setStat(2800, password);
	player reconnect();

	self pm(fmt("^5Account linked. %s has received their password", player.name));
}

cmd_FutureLink(args)
{
	if (args.size < 1)
		return self pm("Usage: !link <playerNum>");

	player = getPlayerByNum(args[0]);

	if (!isDefined(player))
		return self pm("^1Could not find player");

	self pm(fmt("You are about to link ^5%s ^7to account ^5%s^7.", player.name, player.id));
	wait 0.05;
	self pm("Make sure this is the right person, this will ^5grant them the password to this account. ^7Type ^2!confirm ^7to proceed");

	response = self confirmation();
	if (!hasConfirmed(response))
		return;

	critical_enter("mysql");

	password = generateToken(9);

	request = SQL_Prepare("UPDATE players SET password = ? WHERE player = ?");
	SQL_BindParam(request, password, level.MYSQL_TYPE_STRING);
	SQL_BindParam(request, player.id, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);
	SQL_Free(request);

	critical_release("mysql");

	player.admin_register = true;
	player setPersistence("register", player.admin_register);
	player clientcmd(fmt("bind F9 say $login %s", password));

	player pm("^2An admin has verified your account. Press ^5F9 ^2to log in");
	wait 0.05;
	player pm(fmt("^2Player: ^5%s ^2Password: ^5%s", player.id, password));
	wait 0.05;
	player pm("^5Take a screenshot in case you lose your profile");
	wait 0.05;

	self pm(fmt("^5Account linked. %s has received their password", player.name));
}

cmd_FutureRegister(args)
{
	if (self isRegister())
		return self pm("This account already exists");

	password = generateToken(9);

	critical_enter("mysql");

	request = SQL_Prepare("UPDATE players SET password = ? WHERE player = ?");
	SQL_BindParam(request, password, level.MYSQL_TYPE_STRING);
	SQL_BindParam(request, self.id, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);
	SQL_Free(request);

	critical_release("mysql");

	self.admin_register = true;
	self setPersistence("register", self.admin_register);
	self clientcmd(fmt("bind F9 say $login %s", password));

	self pm("^2Account created! Press ^5F9 ^2to log in");
	wait 0.05;
	self pm(fmt("^2Player: ^5%s ^2Password: ^5%s", self.id, password));
	wait 0.05;
	self pm("^5Take a screenshot in case you lose your profile");
}

cmd_FutureLogin(args)
{
	if (self isAuth())
		return self pm("You are already logged in");

	if (args.size < 1)
	{
		self pm("Usage: !login <password>");
		self pm("You can also press the ^5F9 ^7key");
		self pm("Contact an admin if this account ^5is not linked yet^7 or if you ^1lost your password");
		return;
	}
	password = args[0];

	critical_enter("mysql");

	request = SQL_Prepare("SELECT role, vip FROM players WHERE player = ? AND password = ?");
	SQL_BindParam(request, self.id, level.MYSQL_TYPE_STRING);
	SQL_BindParam(request, password, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);
	row = SQL_FetchRowDict(request);
	SQL_Free(request);

	critical_release("mysql");

	if (!isDefined(row))
	{
		self pm("^1Incorrect password");
		return;
	}
	self.admin_auth = true;
	self.admin_role = row["role"];
	self.admin_vip = row["vip"];

	self setPersistence("auth", self.admin_auth);
	self setPersistence("role", self.admin_role);
	self setPersistence("vip", self.admin_vip);

	self setClientDvar("sr_admin_role", self getRoleName());

	self playLocalSound("change_way");
	self pm("^5Logged in");
}
