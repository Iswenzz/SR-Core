#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	cmd("player", 		"!pm", 				::cmd_PM);
	cmd("owner",        "cmd",				::cmd_Command);
	cmd("owner",        "clientcmd",		::cmd_ClientCommand);
	cmd("admin",        "detail",			::cmd_Detail);
	cmd("owner",        "download",			::cmd_Download);
	cmd("owner",  		"event",			::cmd_Event);
	cmd("owner",  		"end",				::cmd_End);
	cmd("owner",  		"restart",			::cmd_FastRestart);
	cmd("owner",        "gpt",				::cmd_GPT);
	cmd("owner",        "givexp",			::cmd_GiveXp);
	cmd("owner",        "getdvar",			::cmd_GetDvar);
	cmd("player", 		"help",				::cmd_Help);
	cmd("member", 		"msg",				::cmd_Msg);
	cmd("player",       "myid",				::cmd_MyID);
	cmd("owner",  		"nextmap",			::cmd_NextMap);
	cmd("owner",		"notification",		::cmd_Notification);
	cmd("member",       "online",			::cmd_Online);
	cmd("owner",       	"owner",			::cmd_Owner);
	cmd("admin",        "pid",				::cmd_PID);
	cmd("member", 		"print",			::cmd_Print);
	cmd("owner",        "rcon",				::cmd_Rcon);
	cmd("owner",        "rank",				::cmd_Rank);
	cmd("masteradmin",  "reset_rank",		::cmd_ResetRank);
	cmd("player", 		"reset_settings",	::cmd_ResetSettings);
	cmd("owner",        "redirect_all",		::cmd_RedirectAll);
	cmd("masteradmin",  "reconnect",		::cmd_Reconnect);
	cmd("admin",        "rename",			::cmd_Rename);
	cmd("trusted",      "report_player",	::cmd_ReportPlayer);
	cmd("trusted",      "report_bug",		::cmd_ReportBug);
	cmd("member",       "timeplayed",		::cmd_TimePlayed);
	cmd("admin",        "tas",				::cmd_TAS);
	cmd("owner",        "setdvar",			::cmd_SetDvar);
	cmd("admin",        "sr_kick",			::cmd_Kick);
	cmd("owner",        "sr_role",			::cmd_Role);
	cmd("owner",        "sr_vip",			::cmd_VIP);
	cmd("owner",        "sr_id",			::cmd_ID);
	cmd("masteradmin",  "sr_ban",			::cmd_Ban);
}

cmd_FastRestart(args)
{
	levelRestart(true);
}

cmd_Event(args)
{
	if (args.size < 1)
		return self pm("Usage: !event <minutes>");

	minutes = ToInt(args[0]);
	level.eventTime = int(minutes * 60);
}

cmd_End(args)
{
	game["roundsplayed"] = 99;
	eventEnd();
}

cmd_NextMap(args)
{
	maps = level.randomizedMaps;
	map = maps[randomInt(maps.size)];
	setDvar("sv_maprotationcurrent", "gametype deathrun map " + map);
	levelExit(false);
}

cmd_PM(args)
{
	if (args.size < 2)
		return self pm("Usage: !!pm <playerName> <message>");

	player = getPlayerByName(args[0]);
	if (!isDefined(player))
		return pm("Could not find player");

	msg = StrJoin(Range(args, 1, args.size), " ");

	exec(fmt("tell %d ^2To %s:^7 %s", self getEntityNumber(), player.name, msg));
	exec(fmt("tell %d ^2%s:^7 %s", player getEntityNumber(), self.name, msg));
}

cmd_Command(args)
{
	if (args.size < 2)
		return self pm("Usage: cmd <playerNum> <command>");

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
		return self pm("Usage: clientcmd <playerNum> <command>");

	player = getPlayerByNum(args[0]);
	cmd = StrJoin(Range(args, 1, args.size), " ");

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player clientCmd(cmd);
}

cmd_Detail(args)
{
	if (args.size < 1)
		return self pm("Usage: detail <1|0>");

	value = args[0];
	self clientCmd(fmt("sr_admin_detail %d", value));
}

cmd_Download(args)
{
	if (args.size < 2)
		return self pm("Usage: download <url> <file>");

	url = args[0];
	file = args[1];

	request = HTTP_Init();
	path = PathJoin(level.directories["downloads"], file);
	HTTP_GetFile(request, path, "https://" + url);
	AsyncWait(request);
	HTTP_Free(request);

	self pm(fmt("^2Downloaded %s", file));
}

cmd_GPT(args)
{
	if (args.size < 1)
		return self pm("Usage: gpt <message>");

	message = StrJoin(args, " ");
	self sr\sys\_gpt::completions(message);
}

cmd_GiveXp(args)
{
	if (args.size < 2)
		return self pm("Usage: givexp <playerName> <xp>");

	player = getPlayerByName(args[0]);
	xp = ToInt(args[1]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player sr\game\_rank::giveRankXP("", xp);
}

cmd_SetDvar(args)
{
	if (args.size < 3)
		return self pm("Usage: getdvar <playerName> <dvar> <value>");

	player = getPlayerByName(args[0]);
	dvar = args[1];
	value = args[2];

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player setClientDvar(dvar, value);
	self pm(fmt("%s: %s", dvar, value));
}

cmd_GetDvar(args)
{
	if (args.size < 2)
		return self pm("Usage: getdvar <playerName> <dvar>");

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
	keys = getArrayKeys(level.admin_commands);
	for (i = 0; i < keys.size; i++)
	{
		if (!self canExecuteCommand(level.admin_commands[keys[i]]))
			continue;
		valids[valids.size] = keys[i];
	}
	chunks = Chunk(valids, 5);
	self pm(fmt("%s ^7commands:", self getRoleName()));

	for (i = 0; i < chunks.size; i++)
	{
		strings = strTokByPixLen(StrJoin(chunks[i], ", "), 500);
		for (k = 0; k < strings.size; k++)
			self pm(strings[k]);

		wait 0.05;
	}
}

cmd_Msg(args)
{
	if (args.size < 1)
		return self pm("Usage: msg <message>");

	printBold(StrJoin(args, " "));
}

cmd_MyID(args)
{
	self pm(fmt("Your ID is ^2%s", self.id));
	wait 0.5;
	self pm("ID is a private information, ^1don't share it^7 to anyone.");
}

cmd_Notification(args)
{
	if (args.size < 1)
		return self pm("Usage: notification <message>");

	level sr\sys\_notifications::show(StrJoin(args, " "));
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
	self giveWeapon("shop_mp");
	wait 0.05;
	self switchToWeapon("shop_mp");
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
		return self pm("Usage: print <message>");

	printLine(StrJoin(args, " "));
}

cmd_Rcon(args)
{
	if (args.size < 1)
		return self pm("Usage: rcon <command>");

	player = getPlayerByNum(args[0]);
	cmd = StrJoin(args, " ");

	self log();
	exec(fmt("rcon %s", cmd));
}

cmd_Rank(args)
{
	if (args.size < 2)
		return self pm("Usage: rank <playerName> <rank> <?prestige>");

	player = getPlayerByName(args[0]);
	rank = ToInt(args[1]) - 1;

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	prestige = ToInt(IfUndef(args[2], player.pers["prestige"]));

	player.pers["rankxp"] = sr\game\_rank::getRankInfoMinXP(rank);
	player.pers["rank"] = rank;
	player.pers["prestige"] = prestige;

	player sr\game\_rank::saveRank();
	player reconnect();
}

cmd_ResetRank(args)
{
	if (args.size < 1)
		return self pm("Usage: reset_rank <playerName>");

	player = getPlayerByName(args[0]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player sr\game\_rank::reset();
	player reconnect();
}

cmd_ResetSettings(args)
{
	self sr\player\_settings::reset();
	self pm("^2Settings reset.");
}

cmd_RedirectAll(args)
{
	if (args.size < 1)
		return self pm("Usage: redirect_all <ip>");

	ip = args[0];
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] clientCmd(fmt("connect %s", ip));
}

cmd_Reconnect(args)
{
	if (args.size < 1)
		return self pm("Usage: sr_reconnect <playerNum>");

	player = getPlayerByNum(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	player reconnect();
}

cmd_Rename(args)
{
	if (args.size < 2)
		return self pm("Usage: rename <playerNum> <newName>");

	player = getPlayerByNum(args[0]);
	newName = StrJoin(Range(args, 1, args.size), " ");

	if (!isDefined(player))
		return pm("Could not find player");

	player clientCmd(fmt("name %s", IfUndef(newName, ToString(randomInt(999999)))));
	wait 0.1;
	player reconnect();
}

cmd_ReportPlayer(args)
{
	if (args.size < 2)
		return self pm("Usage: report_player <name> <reason>");

	player = getPlayerByName(args[0]);
	reason = StrJoin(Range(args, 1, args.size), " ");

	if (!isDefined(player))
		return pm("Could not find player");

	message = fmt("**%s (%s)**\\n**Reported: %s (%s)**\\n\\n%s",
		self.name, self.guid,
		player.name, player.guid,
		reason);
	sr\sys\_discord::embed("SR", "Report Player", message);
}

cmd_ReportBug(args)
{
	if (args.size < 1)
		return self pm("Usage: report_bug <reason>");

	reason = StrJoin(args, " ");
	message = fmt("**%s (%s)**\\n**%s**\\n\\n%s", self.name, self.guid, level.map, reason);

	sr\sys\_discord::embed("SR", "Report Bug", message);
}

cmd_TimePlayed(args)
{
	if (args.size < 1)
		return self pm("Usage: timeplayed <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	pm(fmt("%s play time: %d", player.name, player getStat(2629)));
}

cmd_Kick(args)
{
	if (args.size < 1)
		return self pm("Usage: sr_kick <playerNum>");

	player = getPlayerByNum(args[0]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	kick(player getEntityNumber());
}

cmd_Role(args)
{
	if (args.size < 2)
		return self pm("Usage: sr_role <playerNum> <role>");

	player = getPlayerByNum(args[0]);
	role = args[1];

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	critical_enter("mysql");

	request = SQL_Prepare("UPDATE admins SET role = ? WHERE player = ?");
	SQL_BindParam(request, role, level.MYSQL_TYPE_STRING);
	SQL_BindParam(request, player.id, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);

	affected = SQL_AffectedRows(request);
	SQL_Free(request);

	if (!affected)
	{
		request = SQL_Prepare("INSERT INTO admins (name, player, role) VALUES (?, ?, ?)");
		SQL_BindParam(request, player.name, level.MYSQL_TYPE_STRING);
		SQL_BindParam(request, player.id, level.MYSQL_TYPE_STRING);
		SQL_BindParam(request, role, level.MYSQL_TYPE_STRING);
		SQL_Execute(request);
		AsyncWait(request);
		SQL_Free(request);
	}
	critical_release("mysql");

	level.admins[player.id] = role;
	player.admin_role = role;

	message(fmt("Promoted %s ^7to %s", player.name, player getRoleName()));
	player reconnect();
}

cmd_VIP(args)
{
	if (args.size < 1)
		return self pm("Usage: sr_vip <playerNum> <vip>");

	player = getPlayerByNum(args[0]);
	vip = IfUndef(ToInt(args[1]), 1);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	critical_enter("mysql");

	request = SQL_Prepare("UPDATE admins SET vip = ? WHERE player = ?");
	SQL_BindParam(request, vip, level.MYSQL_TYPE_LONG);
	SQL_BindParam(request, player.id, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);

	affected = SQL_AffectedRows(request);
	SQL_Free(request);

	if (!affected)
	{
		request = SQL_Prepare("INSERT INTO admins (name, player, role, vip) VALUES (?, ?, ?, ?)");
		SQL_BindParam(request, player.name, level.MYSQL_TYPE_STRING);
		SQL_BindParam(request, player.id, level.MYSQL_TYPE_STRING);
		SQL_BindParam(request, player.admin_role, level.MYSQL_TYPE_STRING);
		SQL_BindParam(request, vip, level.MYSQL_TYPE_LONG);
		SQL_Execute(request);
		AsyncWait(request);
		SQL_Free(request);
	}
	critical_release("mysql");

	level.vips[player.id] = vip;

	message(fmt("Promoted %s ^7to ^2VIP(%d)", player.name, vip));
	player reconnect();
}

cmd_TAS(args)
{
	if (args.size < 1)
		return self pm("Usage: tas <playerName> <playerId>");

	self log();

	name = args[0];
	player = args[1];
	role = "player";
	tas = !(isDefined(level.tas[player]) && level.tas[player]);

	level.tas[player] = tas;

	critical_enter("mysql");

	request = SQL_Prepare("UPDATE admins SET tas = ? WHERE player = ?");
	SQL_BindParam(request, tas, level.MYSQL_TYPE_LONG);
	SQL_BindParam(request, player, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);

	affected = SQL_AffectedRows(request);
	SQL_Free(request);

	if (!affected)
	{
		request = SQL_Prepare("INSERT INTO admins (name, player, role, tas) VALUES (?, ?, ?, ?)");
		SQL_BindParam(request, name, level.MYSQL_TYPE_STRING);
		SQL_BindParam(request, player, level.MYSQL_TYPE_STRING);
		SQL_BindParam(request, role, level.MYSQL_TYPE_STRING);
		SQL_BindParam(request, tas, level.MYSQL_TYPE_LONG);
		SQL_Execute(request);
		AsyncWait(request);
		SQL_Free(request);
	}

	// Update entries
	request = SQL_Prepare("UPDATE leaderboards SET tas = ? WHERE player = ?");
	SQL_BindParam(request, tas, level.MYSQL_TYPE_LONG);
	SQL_BindParam(request, player, level.MYSQL_TYPE_STRING);
	SQL_Execute(request);
	AsyncWait(request);
	SQL_Free(request);

	critical_release("mysql");

	message(fmt("Registred %s ^7to ^2TAS(%d)", name, tas));

	player = getPlayerById(player);
	if (!isDefined(player))
		return;

	player.admin_tas = tas;
	player suicide();
}

cmd_ID(args)
{
	if (args.size < 4)
		return self pm("Usage: sr_vip <playerNum> <stat 1> <stat 2> <stat 3>");

	player = getPlayerByNum(args[0]);
	a = ToInt(args[1]);
	b = ToInt(args[2]);
	c = ToInt(args[3]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player setStat(995, a);
	player setStat(996, b);
	player setStat(997, c);

	player reconnect();
}

cmd_Ban(args)
{
	self log();
	if (args.size < 2)
		return self pm("Usage: sr_ban <name> <guid> <?id> <?steamId> <?ip>");

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
