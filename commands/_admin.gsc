#include sr\utils\_common;

main()
{
	cmd("owner",        "cmd",			::cmd_Command);
	cmd("admin",        "detail",		::cmd_Detail);
	cmd("owner",        "getdvar",		::cmd_GetDvar);
	cmd("player", 		"help",			::cmd_Help);
	cmd("member",       "msg",			::cmd_Msg);
    cmd("player",       "myid",			::cmd_MyID);
	cmd("member",       "online",		::cmd_Online);
	cmd("owner",       	"owner",		::cmd_Owner);
	cmd("admin",        "pid",			::cmd_PID);
	cmd("owner",        "rank",			::cmd_Rank);
	cmd("masteradmin",  "rank_reset",	::cmd_RankReset);
	cmd("owner",        "redirect_all",	::cmd_RedirectAll);
	cmd("masteradmin",  "reconnect",	::cmd_Reconnect);
	cmd("admin",        "rename",		::cmd_Rename);
	cmd("member",       "report_player",::cmd_ReportPlayer);
	cmd("member",       "report_bug",	::cmd_ReportBug);
	cmd("member",       "timeplayed"	::cmd_TimePlayed);
	cmd("admin",        "sr_kick"		::cmd_Kick);
	cmd("owner",        "sr_group"		::cmd_Group);
	cmd("owner",        "sr_vip"		::cmd_VIP);
	cmd("owner",        "sr_id"			::cmd_ID);
	cmd("masteradmin",  "sr_ban"		::cmd_Ban);
}

cmd_Command(args)
{
	if (args.size < 2)
		return self sr\sys\_admins::pm("Usage: cmd <playerName> <\"command\">");

	player = getPlayerByName(args[0]);
	cmd = args[1];

	self sr\sys\_admins::log();
	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	player clientCmd(cmd);
}

cmd_Detail(args)
{
	if (args.size < 1)
		return self sr\sys\_admins::pm("Usage: detail <1|0>");

	value = args[0];
	self clientCmd(fmt("sr_admin_detail %d", value));
}

cmd_GetDvar(args)
{
	if (args.size < 2)
		return self sr\sys\_admins::pm("Usage: cmd <playerName> <dvar>");

	player = getPlayerByName(args[0]);
	dvar = args[1];

	self sr\sys\_admins::log();
	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	value = player getClientDvar(dvar);
	self sr\sys\_admins::pm("%s: %s", dvar, value);
}

cmd_Help()
{
	cmds = Where(keys, ::sr\sys\_admins::canExecuteCommand);
	string = StrJoin(cmds, ",");

	self sr\sys\_admins::pm(fmt("%s commands:", self.admin_group));
	self sr\sys\_admins::pm(string);
}

cmd_Msg(args)
{
	if (args.size < 1)
		return self sr\sys\_admins::pm("Usage: msg <message>");

	msg = args[0];
	iPrintLnBold(msg);
}

cmd_MyID()
{
	self self sr\sys\_admins::pm(fmt("Your ID is ^2%s", self.playerID));
	wait 0.5;
	self self sr\sys\_admins::pm("Please make a note of your ID");
}

cmd_Online()
{
	strings = [];
	index = 0;

	// Chunks
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		current = strings[index];

		if (i % 5)
			index++;
		if (!isDefined(current))
			current = [];

		current[current.size] = fmt("%s[%s]", player.name, player getGroupString());
	}

	// Display
	for (i = 0; i < strings.size; i++)
	{
		message = StrJoin(strings[i], ",");
		sr\sys\_admins::message(message);
	}
}

cmd_Owner()
{
	self giveWeapon("shop_mp");
	self switchToWeapon("shop_mp");
}

cmd_PID()
{
	players = getAllPlayers();
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		self iPrintLn(fmt("^2Name:^7 %s ^3PID:^7 %s ^5ID:^7 %s ^5GUID:^7 %s",
			player.name, player getEntityNumber(), player.playerID, player.guid));
	}
}

cmd_Rank()
{
	if (args.size < 3)
		return self sr\sys\_admins::pm("Usage: rank <playerName> <rank> <?prestige>");

	player = getPlayerByName(args[0]);
	rank = ToInt(args[1]);
	prestige = ToInt(args[2]);

	self sr\sys\_admins::log();
	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	if (isDefined(prestige))
		player.pers["prestige"] = prestige;
	xp = int(TableLookup("mp/rankTable.csv", 0, rank - 1, 2));
	player sr\game\_rank::giveRankXP("setrank", xp);
}

cmd_RankReset(args)
{
	if (args.size < 1)
		return self sr\sys\_admins::pm("Usage: rank_reset <playerName>");

	player = getPlayerByName(args[0]);

	self sr\sys\_admins::log();
	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	player sr\game\_rank::reset();
}

cmd_RedirectAll(args)
{
	if (args.size < 1)
		return self sr\sys\_admins::pm("Usage: redirect_all <ip>");

	ip = args[0];
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] clientCmd(fmt("connect %s", ip));
}

cmd_Reconnect(args)
{
	if (args.size < 1)
		return self sr\sys\_admins::pm("Usage: reconnect <playerNum>");

	player = getPlayerByNum(args[0]);

	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	player clientCmd("reconnect");
}

cmd_Rename(args)
{
	if (args.size < 2)
		return self sr\sys\_admins::pm("Usage: rename <playerNum> <newName>");

	player = getPlayerByNum(args[0]);
	newName = args[1];

	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	player clientCmd(fmt("name %s", IfDefined(newName, ToString(randomInt(999999)))));
	wait 0.1;
	player clientCmd("reconnect");
}

cmd_ReportPlayer(args)
{
	if (args.size < 2)
		return self sr\sys\_admins::pm("Usage: report_player <name> <reason>");

	player = getPlayerByName(args[0]);
	reason = args[1];

	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");
	
	message = fmt("reporter: %s[%s]\nplayer: %s[%s]\nreason: %s",
		self.name, self.guid,
		player.name, player.guid,
		reason);
	sr\sys\_discord::embed(level.discord_report, message);
}

cmd_ReportBug(args)
{
	if (args.size < 1)
		return self sr\sys\_admins::pm("Usage: report_bug <reason>");

	reason = args[0];
	
	message = fmt("reporter: %s[%s]\nreason: %s",
		self.name, self.guid,
		reason);
	sr\sys\_discord::embed(level.discord_report, message);
}

cmd_TimePlayed(args)
{
	if (args.size < 1)
		return self sr\sys\_admins::pm("Usage: timeplayed <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	playTime = player getStat(2314);
	sr\sys\_admins::pm("%s play time: %d", player.name, playTime);
}

cmd_Kick(args)
{
	if (args.size < 1)
		return self sr\sys\_admins::pm("Usage: sr_kick <playerName>");

	player = getPlayerByName(args[0]);

	self sr\sys\_admins::log();
	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	kick(player getEntityNumber());
}

cmd_Group(args)
{
	if (args.size < 2)
		return self sr\sys\_admins::pm("Usage: sr_group <playerNum> <group>");

	player = getPlayerByNum(args[0]);
	group = args[1];

	self sr\sys\_admins::log();
	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	sr\sys\_mysql::prepare("UPDATE admins SET group = ? WHERE id = ?");
	SQL_BindParam(group, level.MYSQL_TYPE_STRING);
	SQL_BindParam(player.playerID, level.MYSQL_TYPE_LONG);
	sr\sys\_mysql::execute();

	if (!SQL_AffectedRows())
	{
		sr\sys\_mysql::prepare("INSERT INTO admins (name, id, group) VALUES (?, ?, ?)");
		SQL_BindParam(player.name, level.MYSQL_TYPE_STRING);
		SQL_BindParam(player.playerID, level.MYSQL_TYPE_LONG);
		SQL_BindParam(group, level.MYSQL_TYPE_STRING);
		sr\sys\_mysql::execute();
	}
}

cmd_VIP(args)
{
	if (args.size < 1)
		return self sr\sys\_admins::pm("Usage: sr_vip <playerNum> <vip>");

	player = getPlayerByNum(args[0]);
	vip = IfDefined(ToInt(args[1]), 1);

	self sr\sys\_admins::log();
	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	sr\sys\_mysql::prepare("UPDATE admins SET vip = ? WHERE id = ?");
	SQL_BindParam(vip, level.MYSQL_TYPE_STRING);
	SQL_BindParam(player.playerID, level.MYSQL_TYPE_LONG);
	sr\sys\_mysql::execute();

	if (!SQL_AffectedRows())
	{
		sr\sys\_mysql::prepare("INSERT INTO admins (name, id, group, vip) VALUES (?, ?, ?, ?)");
		SQL_BindParam(player.name, level.MYSQL_TYPE_STRING);
		SQL_BindParam(player.playerID, level.MYSQL_TYPE_LONG);
		SQL_BindParam(player.admin_group, level.MYSQL_TYPE_STRING);
		SQL_BindParam(vip, level.MYSQL_TYPE_LONG);
		sr\sys\_mysql::execute();
	}
}

cmd_ID(args)
{
	if (args.size < 4)
		return self sr\sys\_admins::pm("Usage: sr_vip <playerNum> <stat 1> <stat 2> <stat 3>");

	player = getPlayerByNum(args[0]);
	a = ToInt(args[1]);
	b = ToInt(args[2]);
	c = ToInt(args[3]);

	self sr\sys\_admins::log();
	if (!isDefined(player))
		return sr\sys\_admins::pm("Could not find player");

	player setStat(995, a);
	player setStat(996, b);
	player setStat(997, c);
}

cmd_Ban(args)
{
	if (args.size < 2)
		return self sr\sys\_admins::pm("Usage: sr_ban <name> <guid> <pid> <steamid> <ip>");

	name = args[0];
	guid = args[1];
	pid = args[2];
	steamid = args[3];
	ip = args[4];

	sr\sys\_mysql::prepare("INSERT INTO bans (name, guid, pid, steamid, ip) VALUES (?, ?, ?, ?, ?)");
	SQL_BindParam(name, level.MYSQL_TYPE_STRING);
	SQL_BindParam(guid, level.MYSQL_TYPE_STRING);
	SQL_BindParam(pid, level.MYSQL_TYPE_STRING);
	SQL_BindParam(steamid, level.MYSQL_TYPE_STRING);
	SQL_BindParam(ip, level.MYSQL_TYPE_STRING);
	sr\sys\_mysql::execute();
}
