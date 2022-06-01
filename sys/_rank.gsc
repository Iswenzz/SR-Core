#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.scoreInfo = [];
	level.rankTable = [];

	precacheShader("white");

	precacheString(&"RANK_PLAYER_WAS_PROMOTED_N");
	precacheString(&"RANK_PLAYER_WAS_PROMOTED");
	precacheString(&"RANK_PROMOTED");
	precacheString(&"MP_PLUS");
	precacheString(&"BRAXI_CHARACTER_NEW");
	precacheString(&"BRAXI_SPRAY_NEW");

	registerScoreInfo("kill", 10);
	registerScoreInfo("headshot", 25);
	registerScoreInfo("melee", 15);
	registerScoreInfo("activator", 0);
	registerScoreInfo("trap_activation", 10);
	registerScoreInfo("jumper_died", 10);

	registerScoreInfo("win", 0);
	registerScoreInfo("loss", 0);
	registerScoreInfo("tie", 0);

	level.maxRank = int(tableLookup("mp/rankTable.csv", 0, "maxrank", 1));
	level.maxPrestige = int(tableLookup("mp/rankIconTable.csv", 0, "maxprestige", 1));

	pId = 0;
	rId = 0;
	for (pId = 0; pId <= level.maxPrestige; pId++)
	{
		for (rId = 0; rId <= level.maxRank; rId++)
			precacheShader(tableLookup("mp/rankIconTable.csv", 0, rId, pId + 1));
	}

	rankId = 0;
	rankName = tableLookup("mp/ranktable.csv", 0, rankId, 1);
	assert(isDefined(rankName) && rankName != "");

	while (isDefined(rankName) && rankName != "")
	{
		level.rankTable[rankId][1] = tableLookup("mp/ranktable.csv", 0, rankId, 1);
		level.rankTable[rankId][2] = tableLookup("mp/ranktable.csv", 0, rankId, 2);
		level.rankTable[rankId][3] = tableLookup("mp/ranktable.csv", 0, rankId, 3);
		level.rankTable[rankId][7] = tableLookup("mp/ranktable.csv", 0, rankId, 7);

		precacheString(tableLookupIString("mp/ranktable.csv", 0, rankId, 16));

		rankId++;
		rankName = tableLookup("mp/ranktable.csv", 0, rankId, 1);
	}

	level thread onPlayerConnect();
}

sr_reset()
{
	self resetEverything();
	updateRankStats(self, 0);
}

setStatFromStat(stat2, stat1)
{
	self setStat(stat1, self getStat(stat2));
}

resetEverything()
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
}

isRegisteredEvent(type)
{
	if (isDefined(level.scoreInfo[type]))
		return true;
	else
		return false;
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
	return int(level.rankTable[rankId][2]);
}

getRankInfoXPAmt(rankId)
{
	return int(level.rankTable[rankId][3]);
}

getRankInfoMaxXp(rankId)
{
	return int(level.rankTable[rankId][7]);
}

getRankInfoFull(rankId)
{
	return tableLookupIString("mp/ranktable.csv", 0, rankId, 16);
}

getRankInfoFullInt(rankId)
{
	return int(tableLookupIString("mp/ranktable.csv", 0, rankId, 16));
}

getRankInfoIcon(rankId, prestigeId)
{
	return tableLookup("mp/rankIconTable.csv", 0, rankId, prestigeId + 1);
}

getRankInfoUnlockWeapon(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 8);
}

getRankInfoUnlockPerk(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 9);
}

getRankInfoUnlockChallenge(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 10);
}

getRankInfoUnlockFeature(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 15);
}

getRankInfoUnlockCamo(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 11);
}

getRankInfoUnlockAttachment(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 12);
}

getRankInfoLevel(rankId)
{
	return int(tableLookup("mp/ranktable.csv", 0, rankId, 13));
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		if (player.isBot)
			continue;

		playerData = player databaseGetRank();

		player.pers["rankxp"] = playerData.rankxp;
		player.pers["rank"] = playerData.rank;
		player.pers["prestige"] = playerData.prestige;
		player.pers["participation"] = 0;
		player.doingNotify = false;
		player.rankUpdateTotal = 0;

		// for keeping track of rank through stat#251 used by menu script
		// attempt to move logic out of menus as much as possible
		player.cur_rankNum = player.pers["rank"];
		assertex(isdefined(player.cur_rankNum), "rank: " + player.pers["rank"] + " does not have an index, check mp/ranktable.csv");
		player setStat(251, player.cur_rankNum);

		player setRank(player.pers["rank"], int(player.pers["prestige"]));
		player setStat(2326, player.pers["prestige"]);
		player setStat(2350, player.pers["rank"]);
		player setStat(2301, player.pers["rankxp"]);

		player thread onPlayerSpawned();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player initUnlockMessage();
	}
}

onJoinedTeam()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("joined_team");
		self thread removeRankHUD();
	}
}

onJoinedSpectators()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("joined_spectators");
		self thread removeRankHUD();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		if (!isdefined(self.huds.rankscroreupdate))
		{
			self.huds.rankscroreupdate = newClientHudElem(self);
			self.huds.rankscroreupdate.horzAlign = "center";
			self.huds.rankscroreupdate.vertAlign = "middle";
			self.huds.rankscroreupdate.alignX = "center";
			self.huds.rankscroreupdate.alignY = "middle";
			self.huds.rankscroreupdate.x = 0;
			self.huds.rankscroreupdate.y = -60;
			self.huds.rankscroreupdate.font = "default";
			self.huds.rankscroreupdate.fontscale = 2.0;
			self.huds.rankscroreupdate.archived = false;
			self.huds.rankscroreupdate.color = (0.5, 0.5, 0.5);
			self.huds.rankscroreupdate maps\mp\gametypes\_hud::fontPulseInit();
		}
	}
}

roundUp(floatVal)
{
	if (int(floatVal) != floatVal)
		return int(floatVal + 1);
	else
		return int(floatVal);
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

	// Update rank
	sr\sys\_mysql::prepare("UPDATE ranks_speedrun SET name = ?, xp = ?, rank = ?, prestige = ? WHERE guid = ?");
	SQL_BindParam(self.name, level.MYSQL_TYPE_STRING);
	SQL_BindParam(xp, level.MYSQL_TYPE_LONG);
	SQL_BindParam(rank + 1, level.MYSQL_TYPE_LONG);
	SQL_BindParam(prestige, level.MYSQL_TYPE_LONG);
	SQL_BindParam(getSubStr(self getGuid(), 24, 32), level.MYSQL_TYPE_STRING);
	sr\sys\_mysql::execute();

	// Insert new rank
	if (!SQL_AffectedRows())
	{
		sr\sys\_mysql::prepare("INSERT INTO ranks_speedrun (name, guid, xp, rank, prestige) VALUES (?, ?, ?, ?, ?)");
		SQL_BindParam(self.name, level.MYSQL_TYPE_STRING);
		SQL_BindParam(getSubStr(self getGuid(), 24, 32), level.MYSQL_TYPE_STRING);
		SQL_BindParam(xp, level.MYSQL_TYPE_LONG);
		SQL_BindParam(rank + 1, level.MYSQL_TYPE_LONG);
		SQL_BindParam(prestige, level.MYSQL_TYPE_LONG);
		sr\sys\_mysql::execute();
	}
}

databaseGetRank()
{
	sr\sys\_mysql::prepare("SELECT guid, xp, rank, prestige FROM ranks_speedrun WHERE guid = ?");
	SQL_BindParam(getSubStr(self getGuid(), 24, 32), level.MYSQL_TYPE_STRING);
	SQL_BindResult(level.MYSQL_TYPE_STRING, 8);
	SQL_BindResult(level.MYSQL_TYPE_LONG);
	SQL_BindResult(level.MYSQL_TYPE_LONG);
	SQL_BindResult(level.MYSQL_TYPE_LONG);
	sr\sys\_mysql::execute();

	// Get user's rank
	s = spawnStruct();
	if (SQL_NumRows())
	{
		row = SQL_FetchRowDict();
		if (isDefined(row))
		{
			s.rankxp = row["xp"];
			s.rank = row["rank"] - 1;
			s.prestige = row["prestige"];
		}
	}
	// Get default rank
	if (!isDefined(s.rankxp))
	{
		// Check for previous rank system - @TODO remove later
		if (!self getStat(3122))
		{
			self setStat(3122, 157);
 			// Random value
			s.rankxp = self getStat(2301);
			s.rank = self getStat(2350);
			s.prestige = self getStat(2326);
			self databaseSetRank(s.rankxp, s.rank, s.prestige);
		}
		else
		{
			s.rankxp = 0;
			s.rank = 0;
			s.prestige = 0;
		}
	}
	return s;
}

prestigeSystem()
{
	if (!isdefined(self.pers["rank"]) || !isdefined(self.pers["rankxp"]) || !isdefined(self.pers["prestige"]))
		return;
	if (self.pers["prestige"] >= level.maxprestige || self.pers["rankxp"] < getrankinfomaxxp(level.maxrank))
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

	iprintln(self.name + " has entered Prestige " + self.pers["prestige"] + " of " + level.maxprestige);

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

	if (isDefined(self.huds.rankscroreupdate))
	{
		if (self.rankUpdateTotal < 0)
		{
			self.huds.rankscroreupdate.label = &"";
			self.huds.rankscroreupdate.color = (1, 0, 0);
		}
		else
		{
			self.huds.rankscroreupdate.label = &"MP_PLUS";
			self.huds.rankscroreupdate.color = (1, 1, 0.5);
		}

		self.huds.rankscroreupdate setValue(self.rankUpdateTotal);
		self.huds.rankscroreupdate.alpha = 0.85;
		self.huds.rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse(self);

		wait 1;
		self.huds.rankscroreupdate fadeOverTime(0.75);
		self.huds.rankscroreupdate.alpha = 0;

		self.rankUpdateTotal = 0;
	}
}

removeRankHUD()
{
	if (isDefined(self.huds.rankscroreupdate))
		self.huds.rankscroreupdate.alpha = 0;
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
	rankName = level.rankTable[rankId][1];
	assert(isDefined(rankName));

	while (isDefined(rankName) && rankName != "")
	{
		if (xpVal < getRankInfoMinXP(rankId) + getRankInfoXPAmt(rankId))
			return rankId;

		rankId++;
		if (isDefined(level.rankTable[rankId]))
			rankName = level.rankTable[rankId][1];
		else
			rankName = undefined;
	}

	rankId--;
	return rankId;
}

getSPM()
{
	rankLevel = (self getRank() % 61) + 1;
	return 3 + (rankLevel * 0.5);
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

	if (level.dvar["dev"])
	{
		iprintln("getRankXP() : " + xp);
		iprintln("newXp : " + newXp);
	}

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
	if (!isdefined(team))
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

		attacker braxi\_rank::giveRankXP("headshot");
		hs = attacker maps\mp\gametypes\_persistence::statGet("headshots");
		attacker maps\mp\gametypes\_persistence::statSet("headshots", hs + 1);
		break;
		case "MOD_MELEE":
		attacker.pers["knifes"]++;

		attacker braxi\_rank::giveRankXP("melee");
		knife = attacker maps\mp\gametypes\_persistence::statGet("MELEE_KILLS");
		attacker maps\mp\gametypes\_persistence::statSet("MELEE_KILLS", knife + 1);
		break;
		default:
		pistol = attacker maps\mp\gametypes\_persistence::statGet("PISTOL_KILLS");

		attacker maps\mp\gametypes\_persistence::statSet("PISTOL_KILLS", pistol + 1);
		attacker braxi\_rank::giveRankXP("kill");
		break;
	}
}

unlockSpray()
{
	for (i = 0; i < level.assets["spray"].size; i++)
	{
		if (self.pers["rank"] == level.assets["spray"][i]["rank"])
		{
			notifyData = spawnStruct();
			notifyData.title = "New Spray!";
			notifyData.description = level.assets["spray"][i]["name"];
			notifyData.icon = level.assets["spray"][i]["shader"];
			notifyData.duration = 2.9;
			self thread unlockMessage(notifyData);
			break;
		}
	}

}

unlockAbility(name)
{
	for (i = 0; i < level.abilityInfo.size; i++)
	{
		if (level.abilityInfo[i]["codeName"] == name)
		{
			notifyData = spawnStruct();
			notifyData.title = "New Ability!";
			notifyData.description = level.abilityInfo[i]["name"];
			notifyData.icon = level.abilityInfo[i]["shader"];
			notifyData.duration = 2.9;

			self thread unlockMessage(notifyData);
			break;
		}
	}
}

unlockCharacter()
{
	for (i = 0; i < level.assets["character"].size; i++)
	{
		if (self.pers["rank"] == level.assets["character"][i]["rank"])
		{
			notifyData = spawnStruct();
			notifyData.title = "New Character Unlocked!";
			notifyData.description = level.assets["character"][i]["name"];
			notifyData.icon = level.assets["character"][i]["shader"];
			notifyData.duration = 2.9;
			self thread unlockMessage(notifyData);
			break;
		}
	}

}

isCharacterUnlocked(num)
{
	if (num >= level.assets["character"].size || num <= -1)
		return false;
	if (self.pers["prestige"] > level.assets["character"][num]["prestige"])
		return true;
	if (self.pers["rank"] >= level.assets["character"][num]["rank"] && self.pers["prestige"] >= level.assets["character"][num]["prestige"])
		return true;
	return false;
}

unlockItem()
{
	for (i = 0; i < level.assets["weapon"].size; i++)
	{
		if (self.pers["rank"] == level.assets["weapon"][i]["rank"])
		{
			notifyData = spawnStruct();
			notifyData.title = "New Weapon!";
			notifyData.description = level.assets["weapon"][i]["name"];
			notifyData.icon = level.assets["weapon"][i]["shader"];
			notifyData.duration = 2.9;
			self thread unlockMessage(notifyData);
			break;
		}
	}
}

unlockKnifeSkin()
{
	for (i = 0; i < level.assets["knifeSkin"].size; i++)
	{
		if (self.pers["prestige"] == level.assets["knifeSkin"][i]["rank"])
		{
			notifyData = spawnStruct();
			notifyData.title = "New Knife Skin!";
			notifyData.description = level.assets["knifeSkin"][i]["name"];
			notifyData.icon = level.assets["knifeSkin"][i]["shader"];
			notifyData.duration = 2.9;
			self thread unlockMessage(notifyData);
			break;
		}
	}
}

unlockKnife()
{
	for (i = 0; i < level.assets["knife"].size; i++)
	{
		if (self.pers["rank"] == level.assets["knife"][i]["rank"])
		{
			notifyData = spawnStruct();
			notifyData.title = "New Knife!";
			notifyData.description = level.assets["knife"][i]["name"];
			notifyData.icon = level.assets["knife"][i]["shader"];
			notifyData.duration = 2.9;
			self thread unlockMessage(notifyData);
			break;
		}
	}
}

isItemUnlocked(num)
{
	if (num > level.numItems || num <= -1)
		return false;
	if (self.pers["prestige"] > level.assets["weapon"][num]["prestige"])
		return true;
	if (self.pers["rank"] >= level.assets["weapon"][num]["rank"] && self.pers["prestige"] >= level.assets["weapon"][num]["prestige"])
		return true;
	return false;
}

isAbilityUnlocked(num)
{
	if (num > level.numAbilities || num <= -1)
		return false;

	if (self.pers["prestige"] >= level.abilityinfo[num]["prestige"])
		return true;

	return false;
}

isSprayUnlocked(num)
{
	if (num >= level.assets["spray"].size || num <= -1)
		return false;
	if (self.pers["prestige"] > level.assets["spray"][num]["prestige"])
		return true;
	if (self.pers["rank"] >= level.assets["spray"][num]["rank"] && self.pers["prestige"] >= level.assets["spray"][num]["prestige"])
		return true;
	return false;
}

isKnifeSkinUnlocked(num)
{
	if (num > level.numKnifeSkins || num <= -1)
		return false;
	if (self.pers["prestige"] >= level.assets["knifeSkin"][num]["rank"])
		return true;
	return false;
}

isKnifeUnlocked(num)
{
	if (num > level.numKnifes || num <= -1)
		return false;
	if (self.pers["prestige"] > level.assets["knife"][num]["prestige"])
		return true;
	if (self.pers["rank"] >= level.assets["knife"][num]["rank"] && self.pers["prestige"] >= level.assets["knife"][num]["prestige"])
		return true;
	return false;
}

isGloveUnlocked(num)
{
	if (num > level.numGlove || num <= -1)
		return false;
	if (self.pers["prestige"] > level.assets["glove"][num]["prestige"])
		return true;
	if (self.pers["rank"] >= level.assets["glove"][num]["rank"] && self.pers["prestige"] >= level.assets["glove"][num]["prestige"])
		return true;
	return false;
}

isFxUnlocked(num)
{
	if (num > level.numFx || num <= -1)
		return false;
	if (self.pers["prestige"] > level.assets["fx"][num]["prestige"])
		return true;
	if (self.pers["rank"] >= level.assets["fx"][num]["rank"] && self.pers["prestige"] >= level.assets["fx"][num]["prestige"])
		return true;
	return false;
}

unlockTrail()
{
	for (i = 0; i < level.trailInfo.size; i++)
	{
		if (self.pers["rank"] == level.trailInfo[i]["rank"])
		{
			notifyData = spawnStruct();
			notifyData.title = "New Trail!";
			notifyData.description = level.trailInfo[i]["name"];
			notifyData.icon = level.trailInfo[i]["shader"];
			notifyData.duration = 2.9;
			self thread unlockMessage(notifyData);
			break;
		}
	}
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

initUnlockMessage()
{
	self.doingUnlockMessage = false;
	self.unlockMessageQueue = [];
}

unlockMessage(notifyData)
{
	self endon("death");
	self endon("disconnect");

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

	self.unlockMessage[1] = braxi\_mod::addTextHud(self, -190, 20, 1, "left", "top", 1.5);
	self.unlockMessage[1] setShader(notifyData.icon, 55, 48);
	self.unlockMessage[1].sort = 992;

	self.unlockMessage[2] = braxi\_mod::addTextHud(self, -130, 23, 1, "left", "top", 1.4);
	self.unlockMessage[2].font = "objective";
	self.unlockMessage[2] setText(notifyData.title);
	self.unlockMessage[2].sort = 993;

	self.unlockMessage[3] = braxi\_mod::addTextHud(self, -130, 40, 1, "left", "top", 1.4);
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
