#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	cmd("player", 		"!pm", 			::cmd_PM);
	cmd("owner",        "cmd",			::cmd_Command);
	cmd("admin",        "detail",		::cmd_Detail);
	cmd("masteradmin",  "end",			::cmd_End);
	cmd("owner",        "givexp",		::cmd_GiveXp);
	cmd("owner",        "getdvar",		::cmd_GetDvar);
	cmd("player", 		"help",			::cmd_Help);
	cmd("member", 		"msg",			::cmd_Msg);
	cmd("player",       "myid",			::cmd_MyID);
	cmd("owner",		"notification",	::cmd_Notification);
	cmd("member",       "online",		::cmd_Online);
	cmd("owner",       	"owner",		::cmd_Owner);
	cmd("admin",        "pid",			::cmd_PID);
	cmd("owner",        "rank",			::cmd_Rank);
	cmd("masteradmin",  "rank_reset",	::cmd_RankReset);
	cmd("owner",        "redirect_all",	::cmd_RedirectAll);
	cmd("masteradmin",  "reconnect",	::cmd_Reconnect);
	cmd("admin",        "rename",		::cmd_Rename);
	cmd("player",       "report_player",::cmd_ReportPlayer); // @todo
	cmd("player",       "report_bug",	::cmd_ReportBug);
	cmd("owner",		"test",			::cmd_Test);
	cmd("member",       "timeplayed",	::cmd_TimePlayed);
	cmd("admin",        "sr_kick",		::cmd_Kick);
	cmd("owner",        "sr_role",		::cmd_Role);
	cmd("owner",        "sr_vip",		::cmd_VIP);
	cmd("owner",        "sr_id",		::cmd_ID);
	cmd("masteradmin",  "sr_ban",		::cmd_Ban);
}

cmd_Test(args)
{
	self sr\api\_player::setPlayerSpeed(600);
	self iPrintLnBold(fmt("speed: %d %f %d %d", self.speed, self.moveSpeedScale, self.gravity, self.jumpHeight));
}

cmd_End(args)
{
	thread sr\game\_map::end();
}

cmd_PM(args)
{
	if (args.size < 2)
		return self pm("Usage: !!pm <playerName> <message>");

	player = getPlayerByName(args[0]);
	msg = StrJoin(Range(args, 1, args.size), " ");

	exec(fmt("tell %d ^2To %s:^7 %s", self getEntityNumber(), player.name, msg));
	exec(fmt("tell %d ^2%s:^7 %s", player getEntityNumber(), self.name, msg));
}

cmd_Command(args)
{
	if (args.size < 2)
		return self pm("Usage: cmd <playerName> <command>");

	player = getPlayerByName(args[0]);
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
	valid = [];
	keys = getArrayKeys(level.admin_commands);
	for (i = 0; i < keys.size; i++)
	{
		if (!self canExecuteCommand(level.admin_commands[keys[i]]))
			continue;
		valid[valid.size] = keys[i];
	}
	chunks = Chunk(valid, 10);

	self pm(fmt("%s ^7commands:", self getRoleName()));
	for (i = 0; i < chunks.size; i++)
	{
		string = StrJoin(chunks[i], ", ");
		self pm(string);
	}
}

cmd_Msg(args)
{
	if (args.size < 1)
		return self pm("Usage: msg <message>");

	iPrintLnBold(StrJoin(args, " "));
}

cmd_MyID(args)
{
	self pm(fmt("Your ID is ^2%s", self.id));
	wait 0.5;
	self pm("Please make a note of your ID");
}

cmd_Notification(args)
{
	if (args.size < 1)
		return self pm("Usage: notification <message>");

	level sr\sys\_notifications::message(StrJoin(args, " "));
}

cmd_Online(args)
{
	strings = [];
	index = 0;

	message("Online:");
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		role = players[i] getRoleName();
		if (role != "Player")
			strings[strings.size] = fmt("%s^7[%s^7]", players[i].name, players[i] getRoleName());
	}
	strings = Chunk(strings, 6);

	for (i = 0; i < strings.size; i++)
	{
		message = StrJoin(strings[i], ", ");
		message(message);
	}
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
	{
		player = players[i];

		self iPrintLn(fmt("^2Name:^7 %s ^3PID:^7 %d ^5ID:^7 %s ^5GUID:^7 %s",
			player.name, player getEntityNumber(), player.id, player.guid));
	}
}

cmd_Rank(args)
{
	if (args.size < 2)
		return self pm("Usage: rank <playerName> <rank> <?prestige>");

	player = getPlayerByName(args[0]);
	rank = ToInt(args[1]) - 1;
	prestige = ToInt(args[2]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	if (isDefined(prestige))
		player.pers["prestige"] = prestige;
	xp = int(TableLookup("mp/ranks.csv", 0, rank, 2));
	player sr\game\_rank::databaseSetRank(xp, rank, prestige);
	player reconnect();
}

cmd_RankReset(args)
{
	if (args.size < 1)
		return self pm("Usage: rank_reset <playerName>");

	player = getPlayerByName(args[0]);

	self log();
	if (!isDefined(player))
		return pm("Could not find player");

	player sr\game\_rank::reset();
	player eventConnect();
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
	newName = StrJoin(args[1], " ");

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
	sr\sys\_discord::webhookEmbed("SR", "Report Player", message);
}

cmd_ReportBug(args)
{
	if (args.size < 1)
		return self pm("Usage: report_bug <reason>");

	reason = StrJoin(args, " ");
	message = fmt("**%s (%s)**\\n**%s**\\n\\n%s", self.name, self.guid, level.map, reason);

	sr\sys\_discord::webhookEmbed("SR", "Report Bug", message);
}

cmd_TimePlayed(args)
{
	if (args.size < 1)
		return self pm("Usage: timeplayed <playerName>");

	player = getPlayerByName(args[0]);

	if (!isDefined(player))
		return pm("Could not find player");

	pm(fmt("%s play time: %d", player.name, player getStat(2631)));
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

	mutex_acquire("mysql");

	SQL_Prepare("UPDATE admins SET role = ? WHERE player = ?");
	SQL_BindParam(role, level.MYSQL_TYPE_STRING);
	SQL_BindParam(player.id, level.MYSQL_TYPE_STRING);
	SQL_Execute();

	if (!SQL_AffectedRows())
	{
		SQL_Prepare("INSERT INTO admins (name, player, role) VALUES (?, ?, ?)");
		SQL_BindParam(player.name, level.MYSQL_TYPE_STRING);
		SQL_BindParam(player.id, level.MYSQL_TYPE_STRING);
		SQL_BindParam(role, level.MYSQL_TYPE_STRING);
		SQL_Execute();
	}
	mutex_release("mysql");

	player.admin_role = role;
	message(fmt("Promoted %s ^7to %s", player.name, player getRoleName()));
	player eventConnect();
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

	mutex_acquire("mysql");

	SQL_Prepare("UPDATE admins SET vip = ? WHERE player = ?");
	SQL_BindParam(vip, level.MYSQL_TYPE_STRING);
	SQL_BindParam(player.id, level.MYSQL_TYPE_STRING);
	SQL_Execute();

	if (!SQL_AffectedRows())
	{
		SQL_Prepare("INSERT INTO admins (name, player, role, vip) VALUES (?, ?, ?, ?)");
		SQL_BindParam(player.name, level.MYSQL_TYPE_STRING);
		SQL_BindParam(player.id, level.MYSQL_TYPE_STRING);
		SQL_BindParam(player.admin_role, level.MYSQL_TYPE_STRING);
		SQL_BindParam(vip, level.MYSQL_TYPE_LONG);
		SQL_Execute();
	}
	mutex_release("mysql");

	message(fmt("Promoted %s ^7to ^2VIP(%d)", player.name, vip));
	player eventConnect();
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
}

cmd_Ban(args)
{
	if (args.size < 2)
		return self pm("Usage: sr_ban <name> <guid> <id> <steamId> <ip>");

	name = args[0];
	guid = args[1];
	id = args[2];
	steamId = args[3];
	ip = args[4];

	mutex_acquire("mysql");

	SQL_Prepare("INSERT INTO bans (name, guid, player, steamId, ip) VALUES (?, ?, ?, ?, ?)");
	SQL_BindParam(name, level.MYSQL_TYPE_STRING);
	SQL_BindParam(guid, level.MYSQL_TYPE_STRING);
	SQL_BindParam(id, level.MYSQL_TYPE_STRING);
	SQL_BindParam(steamId, level.MYSQL_TYPE_STRING);
	SQL_BindParam(ip, level.MYSQL_TYPE_STRING);
	SQL_Execute();

	mutex_release("mysql");
}
