#include sr\sys\_events;
#include sr\utils\_hud;

initRank()
{
	level.scoreInfo = [];
	level.ranks = [];

	level.maxRank = int(tableLookup("mp/ranks.csv", 0, "maxrank", 1));
	level.maxPrestige = int(tableLookup("mp/rankIconTable.csv", 0, "maxprestige", 1));

	precacheShader("white");

	precacheString(&"RANK_PLAYER_WAS_PROMOTED_N");
	precacheString(&"RANK_PLAYER_WAS_PROMOTED");
	precacheString(&"RANK_PROMOTED");
	precacheString(&"MP_PLUS");

	registerScoreInfo("kill", 10);
	registerScoreInfo("headshot", 25);
	registerScoreInfo("melee", 15);
	registerScoreInfo("activator", 0);
	registerScoreInfo("trap_activation", 10);
	registerScoreInfo("jumper_died", 10);

	registerScoreInfo("win", 0);
	registerScoreInfo("loss", 0);
	registerScoreInfo("tie", 0);

	buildRanks();
	buildRanksIcon();

	menu("-1", "prestige", ::prestige);

	event("connect", ::onConnect);
}

buildRanks()
{
	tableName = "mp/rankTable.csv";

	rankId = 0;
	rankName = tableLookup(tableName, 0, rankId, 1);

	while (isDefined(rankName) && rankName != "")
	{
		level.ranks[rankId][1] = tableLookup(tableName, 0, rankId, 1);
		level.ranks[rankId][2] = tableLookup(tableName, 0, rankId, 2);
		level.ranks[rankId][3] = tableLookup(tableName, 0, rankId, 3);
		level.ranks[rankId][7] = tableLookup(tableName, 0, rankId, 7);

		precacheString(tableLookupIString(tableName, 0, rankId, 16));

		rankId++;
		rankName = tableLookup(tableName, 0, rankId, 1);
	}
}

buildRanksIcon()
{
	tableName = "mp/rankIconTable.csv";
	level.assets["rank"] = [];

	for (pId = 0; pId <= level.maxPrestige; pId++)
	{
		for (rId = 0; rId <= level.maxRank; rId++)
		{
			icon = tableLookup(tableName, 0, rId, pId + 1);
			level.assets["rank"][pId][rId] = icon;
			precacheShader(icon);
		}
	}
}

reset()
{
	self.pers["prestige"] = 0;
	self.pers["rank"] = 0;
	self.pers["rankxp"] = 0;

	self setRank(self.pers["rank"], self.pers["prestige"]);

	self setStat(2326, self.pers["prestige"]);
	self setStat(2350, self.pers["rank"]);
	self setStat(2301, self.pers["rankxp"]);

	for (stat = 3200; stat < 3208; stat++)
		self setStat(stat, 0);

	for (stat = 979; stat < 983; stat++)
		self setStat(stat, 0);

	self databaseSetRank(0, 0, 0);
	updateRankStats(self, 0);
}

registerScoreInfo(type, value)
{
	level.scoreInfo[type]["value"] = value;
}

getScoreInfoValue(type)
{
	return (level.scoreInfo[type]["value"]);
}

getScoreInfoLabel(type)
{
	return (level.scoreInfo[type]["label"]);
}

getRankInfoMinXP(rankId)
{
	return int(level.ranks[rankId][2]);
}

getRankInfoXPAmt(rankId)
{
	return int(level.ranks[rankId][3]);
}

getRankInfoMaxXp(rankId)
{
	return int(level.ranks[rankId][7]);
}

getRankInfoFull(rankId)
{
	return tableLookupIString("mp/ranks.csv", 0, rankId, 16);
}

getRankInfoFullInt(rankId)
{
	return int(tableLookupIString("mp/ranks.csv", 0, rankId, 16));
}

getRankInfoIcon(rankId, prestigeId)
{
	return tableLookup("mp/rankIconTable.csv", 0, rankId, prestigeId + 1);
}

onConnect()
{
	self databaseGetRank();
	self.pers["participation"] = 0;
	self.rankUpdateTotal = 0;

	self setStat(251, self.pers["rank"]); // stock
	self setStat(2326, self.pers["prestige"]);
	self setStat(2350, self.pers["rank"]);
	self setStat(2301, self.pers["rankxp"]);
	self setRank(self.pers["rank"], int(self.pers["prestige"]));

	self thread onSpawned();
	self thread onJoinedTeam();
	self thread onJoinedSpectators();
}

onJoinedTeam()
{
	self endon("disconnect");

	while (true)
	{
		self waittill("joined_team");
		self thread removeRankHUD();
	}
}

onJoinedSpectators()
{
	self endon("disconnect");

	while (true)
	{
		self waittill("joined_spectators");
		self thread removeRankHUD();
	}
}

onSpawned()
{
	self endon("disconnect");

	while (true)
	{
		self waittill("spawned_player");

		if (!isDefined(self.huds["xp"]))
		{
			self.huds["xp"] = newClientHudElem(self);
			self.huds["xp"].horzAlign = "center";
			self.huds["xp"].vertAlign = "middle";
			self.huds["xp"].alignX = "center";
			self.huds["xp"].alignY = "middle";
			self.huds["xp"].x = 0;
			self.huds["xp"].y = -60;
			self.huds["xp"].font = "default";
			self.huds["xp"].fontscale = 2.0;
			self.huds["xp"].archived = false;
			self.huds["xp"].color = (0.5, 0.5, 0.5);
			self.huds["xp"] maps\mp\gametypes\_hud::fontPulseInit();
		}
	}
}

giveRankXP(type, value)
{
	self endon("disconnect");

	if (!isDefined(value))
		return;

	self.score += value;
	self.pers["score"] = self.score;

	score = self maps\mp\gametypes\_persistence::statGet("score");
	self maps\mp\gametypes\_persistence::statSet("score", score + value);

	self incRankXP(value);
	self thread updateRankScoreHUD(value);
	self databaseSetRank(self.pers["rankxp"], self.pers["rank"], self.pers["prestige"]);
}

databaseSetRank(xp, rank, prestige)
{
	if (self.isBot)
		return;

	mutex_acquire("mysql");

	// Update rank
	SQL_Prepare("UPDATE ranks SET name = ?, xp = ?, rank = ?, prestige = ? WHERE player = ?");
	SQL_BindParam(self.name, level.MYSQL_TYPE_STRING);
	SQL_BindParam(xp, level.MYSQL_TYPE_LONG);
	SQL_BindParam(rank + 1, level.MYSQL_TYPE_LONG);
	SQL_BindParam(prestige, level.MYSQL_TYPE_LONG);
	SQL_BindParam(getSubStr(self getGuid(), 24, 32), level.MYSQL_TYPE_STRING);
	SQL_Execute();

	// Insert new rank
	if (!SQL_AffectedRows())
	{
		SQL_Prepare("INSERT INTO ranks (name, player, xp, rank, prestige) VALUES (?, ?, ?, ?, ?)");
		SQL_BindParam(self.name, level.MYSQL_TYPE_STRING);
		SQL_BindParam(getSubStr(self getGuid(), 24, 32), level.MYSQL_TYPE_STRING);
		SQL_BindParam(xp, level.MYSQL_TYPE_LONG);
		SQL_BindParam(rank + 1, level.MYSQL_TYPE_LONG);
		SQL_BindParam(prestige, level.MYSQL_TYPE_LONG);
		SQL_Execute();
	}
	mutex_release("mysql");
}

databaseGetRank()
{
	mutex_acquire("mysql");

	SQL_Prepare("SELECT xp, rank, prestige FROM ranks WHERE player = ?");
	SQL_BindParam(getSubStr(self getGuid(), 24, 32), level.MYSQL_TYPE_STRING);
	SQL_BindResult(level.MYSQL_TYPE_LONG);
	SQL_BindResult(level.MYSQL_TYPE_LONG);
	SQL_BindResult(level.MYSQL_TYPE_LONG);
	SQL_Execute();

	if (SQL_NumRows())
	{
		row = SQL_FetchRowDict();
		self.pers["rankxp"] = row["xp"];
		self.pers["rank"] = row["rank"] - 1;
		self.pers["prestige"] = row["prestige"];
	}
	else
	{
		self.pers["rankxp"] = 0;
		self.pers["rank"] = 0;
		self.pers["prestige"] = 0;
	}
	mutex_release("mysql");
}

prestige()
{
	if (!isDefined(self.pers["rank"]) || !isDefined(self.pers["rankxp"]) || !isDefined(self.pers["prestige"]))
		return;
	if (self.pers["prestige"] >= level.maxPrestige || self.pers["rankxp"] < getRankInfoMaxXP(level.maxRank))
	{
		self iprintlnbold("^1Prestige Mode^7 is unavailable!");
		return;
	}
	self.pers["rankxp"] = 1;
	self.pers["rank"] = 0;
	self.pers["prestige"]++;
	self setrank(0, self.pers["prestige"]);
	self maps\mp\gametypes\_persistence::statset("rankxp", 1);

	updaterankstats(self, 0);

	iPrintLn(fmt("%s has entered prestige %d of %d", self.name, self.pers["prestige"], level.maxPrestige));

	self setStat(979, 0);
	self setStat(980, 0);
	self setStat(981, 0);
	self setStat(982, 0);

	self databaseSetRank(self.pers["rankxp"], self.pers["rank"], self.pers["prestige"]);
}

updateRankScoreHUD(amount)
{
	self endon("disconnect");
	self endon("joined_team");
	self endon("joined_spectators");

	if (amount == 0)
		return;

	self notify("update_score");
	self endon("update_score");

	self.rankUpdateTotal += amount;

	wait (0.05);

	if (isDefined(self.huds["xp"]))
	{
		if (self.rankUpdateTotal < 0)
		{
			self.huds["xp"].label = &"";
			self.huds["xp"].color = (1, 0, 0);
		}
		else
		{
			self.huds["xp"].label = &"MP_PLUS";
			self.huds["xp"].color = (1, 1, 0.5);
		}

		self.huds["xp"] setValue(self.rankUpdateTotal);
		self.huds["xp"].alpha = 0.85;
		self.huds["xp"] thread maps\mp\gametypes\_hud::fontPulse(self);

		wait 1;
		self.huds["xp"] fadeOverTime(0.75);
		self.huds["xp"].alpha = 0;

		self.rankUpdateTotal = 0;
	}
}

removeRankHUD()
{
	if (isDefined(self.huds["xp"]))
		self.huds["xp"].alpha = 0;
}

getRank()
{
	rankXp = self.pers["rankxp"];
	rankId = self.pers["rank"];

	if (rankXp < (getRankInfoMinXP(rankId) + getRankInfoXPAmt(rankId)))
		return rankId;
	else
		return self getRankForXp(rankXp);
}

getRankForXp(xpVal)
{
	rankId = 0;
	rankName = level.ranks[rankId][1];
	assert(isDefined(rankName));

	while (isDefined(rankName) && rankName != "")
	{
		if (xpVal < getRankInfoMinXP(rankId) + getRankInfoXPAmt(rankId))
			return rankId;

		rankId++;
		if (isDefined(level.ranks[rankId]))
			rankName = level.ranks[rankId][1];
		else
			rankName = undefined;
	}

	rankId--;
	return rankId;
}

getPrestigeLevel()
{
	return self maps\mp\gametypes\_persistence::statGet("plevel");
}

getRankXP()
{
	return self.pers["rankxp"];
}

incRankXP(amount)
{
	xp = self getRankXP();
	newXp = (xp + amount);

	if (self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP(level.maxRank))
		newXp = getRankInfoMaxXP(level.maxRank);

	self.pers["rankxp"] = newXp;
	self maps\mp\gametypes\_persistence::statSet("rankxp", newXp);

	rankId = self getRankForXp(self getRankXP());
	self updateRank(rankId);
}

updateRank(rankId)
{
	if (getRankInfoMaxXP(self.pers["rank"]) <= self getRankXP() && self.pers["rank"] < level.maxRank)
	{
		rankId = self getRankForXp(self getRankXP());
		self setRank(rankId, self.pers["prestige"]);
		self.pers["rank"] = rankId;
		self updateRankAnnounceHUD();
	}
	updateRankStats(self, rankId);
}

updateRankStats(player, rankId)
{
	player setStat(253, rankId);
	player setStat(255, player.pers["prestige"]);
	player maps\mp\gametypes\_persistence::statSet("rank", rankId);
	player maps\mp\gametypes\_persistence::statSet("minxp", getRankInfoMinXp(rankId));
	player maps\mp\gametypes\_persistence::statSet("maxxp", getRankInfoMaxXp(rankId));
	player maps\mp\gametypes\_persistence::statSet("plevel", player.pers["prestige"]);

	player maps\mp\gametypes\_persistence::statSet("vip", rankId);
	player maps\mp\gametypes\_persistence::statSet("vipplus", player.pers["prestige"]);

	if (rankId > level.maxRank)
		player setStat(252, level.maxRank);
	else
		player setStat(252, rankId);
}

updateRankAnnounceHUD()
{
	self endon("disconnect");

	self notify("update_rank");
	self endon("update_rank");

	team = self.pers["team"];
	if (!isDefined(team))
		return;

	self notify("reset_outcome");
	self.pers["rankstring"] = self.pers["rank"];
	self.pers["rankstring"]++;

	notifyData = spawnStruct();
	notifyData.titleText = &"RANK_PROMOTED";
	notifyData.iconName = self getRankInfoIcon(self.pers["rank"], self.pers["prestige"]);
	notifyData.sound = "mp_level_up";
	notifyData.duration = 4.0;
	notifyData.notifyText = self.pers["rankstring"];
	thread maps\mp\gametypes\_hud_message::notifyMessage(notifyData);
}

processXpReward(sMeansOfDeath, attacker, victim)
{
	if (attacker.pers["team"] == victim.pers["team"])
		return;

	kills = attacker maps\mp\gametypes\_persistence::statGet("kills");
	attacker maps\mp\gametypes\_persistence::statSet("kills", kills + 1);

	if (victim.pers["team"] == "allies")
	{
		kills = attacker maps\mp\gametypes\_persistence::statGet("KILLED_JUMPERS");
		attacker maps\mp\gametypes\_persistence::statSet("KILLED_JUMPERS", kills + 1);
	}
	else
	{
		kills = attacker maps\mp\gametypes\_persistence::statGet("KILLED_ACTIVATORS");
		attacker maps\mp\gametypes\_persistence::statSet("KILLED_ACTIVATORS", kills + 1);
	}

	switch (sMeansOfDeath)
	{
		case "MOD_HEAD_SHOT":
		attacker.pers["headshots"]++;

		attacker giveRankXP("headshot");
		hs = attacker maps\mp\gametypes\_persistence::statGet("headshots");
		attacker maps\mp\gametypes\_persistence::statSet("headshots", hs + 1);
		break;
		case "MOD_MELEE":
		attacker.pers["knifes"]++;

		attacker giveRankXP("melee");
		knife = attacker maps\mp\gametypes\_persistence::statGet("MELEE_KILLS");
		attacker maps\mp\gametypes\_persistence::statSet("MELEE_KILLS", knife + 1);
		break;
		default:
		pistol = attacker maps\mp\gametypes\_persistence::statGet("PISTOL_KILLS");

		attacker maps\mp\gametypes\_persistence::statSet("PISTOL_KILLS", pistol + 1);
		attacker giveRankXP("kill");
		break;
	}
}

isCharacterUnlocked(num)
{
	return isUnlocked(level.assets["character"], num);
}

isWeaponUnlocked(num)
{
	return isUnlocked(level.assets["weapon"], num);
}

isSprayUnlocked(num)
{
	return isUnlocked(level.assets["spray"], num);
}

isKnifeSkinUnlocked(num)
{
	return isUnlocked(level.assets["knifeSkin"], num, 1);
}

isKnifeUnlocked(num)
{
	return isUnlocked(level.assets["knife"], num);
}

isGloveUnlocked(num)
{
	return isUnlocked(level.assets["glove"], num);
}

isFxUnlocked(num)
{
	return isUnlocked(level.assets["fx"], num);
}

isThemeUnlocked(num)
{
	return isUnlocked(level.assets["theme"], num);
}

isUnlocked(assets, num, vip)
{
	if (num > assets.size || num <= -1)
		return 0;
	if (isDefined(vip) && self sr\sys\_admins::isVIP() >= vip)
		return vip;
	if (self.pers["prestige"] < assets[num]["prestige"])
		return 0;
	if (self.pers["rank"] < assets["fx"][num]["rank"])
		return 0;
	return 1;
}

destroyUnlockMessage()
{
	if (!isDefined(self.unlockMessage))
		return;

	for (i = 0; i < self.unlockMessage.size; i++)
		self.unlockMessage[i] destroy();

	self.unlockMessage = undefined;
	self.doingUnlockMessage = false;
}

unlockMessage(notifyData)
{
	self endon("death");
	self endon("disconnect");

	self.doingUnlockMessage = false;
	self.unlockMessageQueue = [];

	if (!self.doingUnlockMessage)
	{
		self thread showUnlockMessage(notifyData);
		return;
	}

	self.unlockMessageQueue[self.unlockMessageQueue.size] = notifyData;
}

showUnlockMessage(notifyData)
{
	self endon("disconnect");

	self playLocalSound("mp_ingame_summary");

	self.doingUnlockMessage = true;
	self.unlockMessage = [];

	self.unlockMessage[0] = newClientHudElem(self);
	self.unlockMessage[0].x = -180;
	self.unlockMessage[0].y = 20;
	self.unlockMessage[0].alpha = 0.76;
	self.unlockMessage[0] setShader("black", 195, 48);
	self.unlockMessage[0].sort = 990;

	self.unlockMessage[1] = addHud(self, -190, 20, 1, "left", "top", 1.5);
	self.unlockMessage[1] setShader(notifyData.icon, 55, 48);
	self.unlockMessage[1].sort = 992;

	self.unlockMessage[2] = addHud(self, -130, 23, 1, "left", "top", 1.4);
	self.unlockMessage[2].font = "objective";
	self.unlockMessage[2] setText(notifyData.title);
	self.unlockMessage[2].sort = 993;

	self.unlockMessage[3] = addHud(self, -130, 40, 1, "left", "top", 1.4);
	self.unlockMessage[3] setText(notifyData.description);
	self.unlockMessage[3].sort = 993;

	for (i = 0; i < self.unlockMessage.size; i++)
	{
		self.unlockMessage[i].horzAlign = "fullscreen";
		self.unlockMessage[i].vertAlign = "fullscreen";
		self.unlockMessage[i].hideWhenInMenu = true;

		self.unlockMessage[i] moveOverTime(notifyData.duration / 4);

		if (i == 1)
			self.unlockMessage[i].x = 11.5;
		else if (i >= 2)
			self.unlockMessage[i].x = 71;
		else
			self.unlockMessage[i].x = 10;
	}

	wait notifyData.duration * 0.8;

	for (i = 0; i < self.unlockMessage.size; i++)
	{
		self.unlockMessage[i] fadeOverTime(notifyData.duration * 0.2);
		self.unlockMessage[i].alpha = 0;
	}

	wait notifyData.duration * 0.2;

	self destroyUnlockMessage();
	self notify("unlockMessageDone");

	if (self.unlockMessageQueue.size > 0)
	{
		nextUnlockMessageData = self.unlockMessageQueue[0];

		newQueue = [];
		for (i = 1; i < self.unlockMessageQueue.size; i++)
			self.unlockMessageQueue[i - 1] = self.unlockMessageQueue[i];
		self.unlockMessageQueue[i - 1] = undefined;

		self thread showUnlockMessage(nextUnlockMessageData);
	}
}
