#include sr\sys\_file;
#include sr\sys\_events;
#include sr\game\minigames\_main;
#include sr\utils\_common;
#include sr\utils\_hud;

initKz()
{
	level.files["kz"] = fmt("sr/data/kz/%s.txt", level.map);

	createMinigame("kz");
	event("killed", ::onPlayerKilled);

	level.kzPoints = [];
	level.kzPlayersInRoom = [];
	level.kzRandomPoints = [];
	level.kzWeapon = "m40a3_mp";
	level.kzWeaponMode = "rng";
	level.kzWeaponList = strTok("m40a3_mp,g3_reflex_mp,m1014_mp,m14_mp,ak47_mp,mp5_acog_mp,ak47_gl_mp,g36c_silencer_mp,m1014_grip_mp,mp5_mp,gl_m14_mp,m60e4_mp,dragunov_mp,p90_acog_mp,rpg_mp,", ",");
	level.kzStarted = false;

	event("spawn", ::hud);

	thread kz();
}

kz()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");

	load();

	while (true)
	{
		level.kzStarted = false;
		level.kzPlayersInRoom = [];
		level.kzRandomPoints = [];

		if (!canStart())
		{
			wait 1;
			continue;
		}

		gameRandomize();
		playerCards();
		sendPlayers();
		watchGame();
		wait 1;
	}
}

hud()
{
	if (!isInQueue("kz"))
		return;

	self.runId = "KillZone";
	self.huds["speedrun"]["name"] setText("^6KillZone");
}

load()
{
	file = FILE_OpenMod(level.files["kz"], "r+");

	while (true)
	{
		line = FILE_ReadLine(file);
		tkn = strTok(line, ",");

		if (IsNullOrEmpty(line) || tkn.size < 4)
			break;

		origin = (ToFloat(tkn[0]), ToFloat(tkn[1]), ToFloat(tkn[2]));
		angle = ToFloat(tkn[3]);

		point = spawnStruct();
		point.origin = origin;
		point.angles = (0, angle, 0);
		level.kzPoints[level.kzPoints.size] = point;
	}
	FILE_Close(file);
}

join()
{
	self endon("disconnect");

	self addToQueue("kz");
	self.sr_cheat = true;
	self.teamKill = true;
	self spawnPlayerInSpec();

	self sr\sys\_admins::message("%s ^7joined the killzone! [^6!kz^7] [^1%s^7]",
		self.name, level.minigames["kz"].queue.size);
}

leave()
{
	self endon("disconnect");
	self removeFromQueue("kz");

	self.kzWonCount = 0;
	self.kzWon = false;
	self sr\game\_teams::setTeam("allies");
	self unlink();
	self.sr_cheat = false;
	self.teamKill = undefined;
	self setClientDvar("cg_drawFriendlyNames", 1);
	self suicide();
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	if (attacker != self && isPlayer(attacker))
	{
		attacker.kzWon = true;
		attacker.kills++;
		attacker.pers["kills"]++;
		sr\game\_rank::processXpReward(sMeansOfDeath, attacker, self);
	}
	deaths = self maps\mp\gametypes\_persistence::statGet("deaths");
	self maps\mp\gametypes\_persistence::statSet("deaths", deaths + 1);
	self.deaths++;
	self.pers["deaths"]++;
}

setWeapon(weapon)
{
	picked = level.kzWeaponList[randomIntRange(0, level.kzWeaponList.size)];
	level.kzWeapon = Ternary(weapon == "rng", picked, weapon);
	level.kzWeaponMode = Ternary(weapon == "rng", "rng", "manual");
}

sendPlayers()
{
	for (i = 0; i < level.minigames["kz"].queue.size; i++)
	{
		if (isDefined(level.minigames["kz"].queue[i]))
			level.minigames["kz"].queue[i] spawnPlayerInSpec();
	}
	for (i = 0; i < level.kzPlayersInRoom.size; i++)
	{
		if (isDefined(level.kzPlayersInRoom[i]))
			level.kzPlayersInRoom[i] thread spawnPlayerInRoom(i);
	}
}

spawnPlayerInRoom(spawnIndex)
{
	self endon("disconnect");

	self.kzWon = false;
	self sr\game\_teams::setTeam("axis");
	self suicide();

	self endon("death");
	self eventSpawn(level.kzRandomPoints[spawnIndex].origin, level.kzRandomPoints[spawnIndex].angles);
	self takeAllWeapons();
	self giveWeapon(level.kzWeapon);
	self giveMaxAmmo(level.kzWeapon);
	wait 0.05;
	self switchToWeapon(level.kzWeapon);
	self setClientDvar("cg_drawFriendlyNames", 0);
}

watchGameTimer()
{
	level endon("kz ended");
	wait 120;
	level notify("kz ended");
}

watchGame()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level notify("kz ended");
	level endon("kz ended");

	level.kzStarted = true;
	thread watchGameTimer();

	while (true)
	{
		wait 0.5;

		if (!Any(level.kzPlayersInRoom, ::isRoomEmpty))
			continue;

		winner = First(level.kzPlayersInRoom, ::isWinner);

		if (isDefined(winner))
		{
			level.kzStarted = false;
			winner.kzWonCount++;
			winner.time = sr\utils\_common::originToTime(getTime() - winner.time.origin);
			winner speedrun\player\huds\_speedrun::updateTime();
			wait 3;
			winner spawnPlayerInSpec();
		}
		level notify("kz ended");
	}
}

isWinner(player, index)
{
	return player.kzWon;
}

isRoomEmpty(player, index)
{
	return level.kzPlayersInRoom.size < 2 || !player isReallyAlive();
}

gameRandomize()
{
	level endon("kz ended");

	r = 1;
	while (r % 2 == 1)
		r = randomIntRange(0, level.kzPoints.size);

	level.kzRandomPoints[0] = level.kzPoints[r];
	level.kzRandomPoints[1] = level.kzPoints[r + 1];
	level.kzPlayersInRoom = pickRandomPlayers("kz", 2);

	if (level.kzWeaponMode == "rng")
		setWeapon("rng");
}

canStart()
{
	if (level.minigames["kz"].queue.size < 2)
		return false;
	if (level.kzPoints.size <= 0)
	{
		iPrintLn("^1KZ ERROR: Kz points not found.");
		ForEachThread(level.minigames["kz"].queue, ::leave);
		return false;
	}
	return true;
}

spawnPlayerInSpec()
{
	self endon("disconnect");
	self sr\game\_teams::setTeam("spectator");
	self eventSpectator();
}

showPlayerCard(attacker, victim)
{
	self endon("disconnect");

	if (attacker == victim || !isPlayer(attacker))
		return;

	self notify("new emblem");
	self endon("new emblem");

	self destroyPlayerCard();

	logo1 = level.assets["rank"][attacker.pers["rank"] - 1]["icon"];
	logo2 = level.assets["rank"][victim.pers["rank"] - 1]["icon"];

	if (attacker.pers["prestige"] > 0)
		logo1 = "rank_prestige" + attacker.pers["prestige"];
	if (victim.pers["prestige"] > 0)
		logo2 = "rank_prestige" + victim.pers["prestige"];

	self.huds["kz_card"] = [];
	self.huds["kz_card"]["background"] = newClientHudElem(self);
	self.huds["kz_card"]["background"].x = 170;
	self.huds["kz_card"]["background"].y = 390;
	self.huds["kz_card"]["background"].alpha = 0;
	self.huds["kz_card"]["background"] setShader("black", 300, 64);
	self.huds["kz_card"]["background"].sort = 990;

	self.huds["kz_card"]["rank_left"] = addHud(self, 0, 390, 0, "left", "top", 1.8);
	self.huds["kz_card"]["rank_left"] setShader(logo1, 64, 64);
	self.huds["kz_card"]["rank_left"].sort = 998;
	self.huds["kz_card"]["rank_left"] moveOverTime(0.44);
	self.huds["kz_card"]["rank_left"].x = 170;

	self.huds["kz_card"]["rank_right"] = addHud(self, 640, 390, 0, "left", "top", 1.8);
	self.huds["kz_card"]["rank_right"] setShader(logo2, 64, 64);
	self.huds["kz_card"]["rank_right"].sort = 998;
	self.huds["kz_card"]["rank_right"] moveOverTime(0.44);
	self.huds["kz_card"]["rank_right"].x = 170 + 300 - 64;

	self.huds["kz_card"]["title"] = addHud(self, 320, 420, 0, "center", "top", 1.5);
	self.huds["kz_card"]["title"] setText(attacker.name + " ^7 VS ^7 " + victim.name);
	self.huds["kz_card"]["title"].sort = 999;
	self.huds["kz_card"]["title"].color = (0.8,0.8,0.8);
	self.huds["kz_card"]["title"].glowColor = (0.6,0.6,0.6);
	self.huds["kz_card"]["title"] setPulseFX(30, 100000, 700);
	self.huds["kz_card"]["title"].glowAlpha = 0.8;

	keys = getArrayKeys(self.huds["kz_card"]);
	for (i = 0; i < keys.size; i++)
	{
		self.huds["kz_card"][keys[i]] fadeOverTime(0.3);
		self.huds["kz_card"][keys[i]].alpha = Ternary(i == 0, 0.5, 1.0);
	}
	wait 3;

	for (i = 0; i < keys.size; i++)
	{
		self.huds["kz_card"][keys[i]] fadeOverTime(0.8);
		self.huds["kz_card"][keys[i]].alpha = 0;
	}
	wait 0.8;

	self destroyPlayerCard();
}

playerCards()
{
	for (i = 0; i < level.minigames["kz"].queue.size; i++)
	{
		if (isDefined(level.minigames["kz"].queue[i]))
			level.minigames["kz"].queue[i] thread showPlayerCard(level.kzPlayersInRoom[0], level.kzPlayersInRoom[1]);
	}
}

destroyPlayerCard()
{
	if (!isDefined(self.huds["kz_card"]))
		return;

	keys = getArrayKeys(self.huds["kz_card"]);
	for (i = 0; i < keys.size; i++)
		self.huds["kz_card"][keys[i]] destroy();
	self.huds["kz_card"] = [];
}
