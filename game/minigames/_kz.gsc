#include sr\sys\_file;
#include sr\game\minigames\_main;
#include sr\utils\_common;

init()
{
	level.file.kz = fmt("sr/data/kz/%s.txt", getDvar("mapname"));

	createMinigame("kz");

	level.kzPoints = [];
	level.kzPlayersInRoom = [];
	level.kzRandomPoints = [];
	level.kzWeapon = "m40a3_mp";
	level.kzWeaponMode = "rng";
	level.kzWeaponList = strTok("m40a3_mp,g3_reflex_mp,m1014_mp,m14_mp,ak47_mp,mp5_acog_mp,ak47_gl_mp,g36c_silencer_mp,m1014_grip_mp,mp5_mp,gl_m14_mp,m60e4_mp,dragunov_mp,p90_acog_mp,rpg_mp", ",");
	level.kzStarted = false;

	load();
	kz();
}

kz()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");

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

load()
{
	file = FILE_OpenMod(level.file.kz, "r+");

	while (true)
	{
		line = FILE_ReadLine(file);
		tkn = strTok(line, ",");

		if (IsNullOrEmpty(line))
			break;
		if (tkn.size < 4)
			continue;

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
	self.sr_cheatmode = true;
	self.canDamage = true;
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
	self.sr_cheatmode = false;
	self.canDamage = undefined;
	self setClientDvar("cg_drawFriendlyNames", 1);
	self suicide();
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
	self braxi\_mod::spawnPlayer(level.kzRandomPoints[spawnIndex].origin, level.kzRandomPoints[spawnIndex].angles);
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
			winner thread speedrun\player\huds\_speedrun::updateHud();
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
		ForEach(level.minigames["kz"].queue, ::leave);
		return false;
	}
	return true;
}

spawnPlayerInSpec()
{
	self endon("disconnect");
	self sr\game\_teams::setTeam("spectator");
	self braxi\_mod::spawnSpectator(level.spawn["spectator"].origin, level.spawn["spectator"].angles);
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

	self.playerCard[0] = newClientHudElem(self);
	self.playerCard[0].x = 170;
	self.playerCard[0].y = 390;
	self.playerCard[0].alpha = 0;
	self.playerCard[0] setShader("black", 300, 64);
	self.playerCard[0].sort = 990;

	self.playerCard[1] = braxi\_mod::addTextHud(self, 0, 390, 0, "left", "top", 1.8);
	self.playerCard[1] setShader(logo1, 64, 64);
	self.playerCard[1].sort = 998;

	self.playerCard[2] = braxi\_mod::addTextHud(self, 640, 390, 0, "left", "top", 1.8);
	self.playerCard[2] setShader(logo2, 64, 64);
	self.playerCard[2].sort = 998;

	self.playerCard[4] = braxi\_mod::addTextHud(self, 320, 420, 0, "center", "top", 1.5);
	self.playerCard[4] setText(attacker.name + " ^7 VS ^7 " + victim.name);
	self.playerCard[4].sort = 999;

	for (i = 3; i < 5; i++)
	{
		self.playerCard[i].color = (0.8,0.8,0.8);
		self.playerCard[i].glowColor = (0.6,0.6,0.6);
		self.playerCard[i] SetPulseFX(30, 100000, 700);
		self.playerCard[i].glowAlpha = 0.8;
	}

	self.playerCard[1] moveOverTime(0.44);
	self.playerCard[1].x = 170;
	self.playerCard[2] moveOverTime(0.44);
	self.playerCard[2].x = 170 + 300 - 64;

	for (i = 0; i < self.playerCard.size; i++)
	{
		self.playerCard[i] fadeOverTime(0.3);
		self.playerCard[i].alpha = Ternary(i == 0, 0.5, 1.0);
	}
	wait 3;

	for (i = 0; i < self.playerCard.size; i++)
	{
		self.playerCard[i] fadeOverTime(0.8);
		self.playerCard[i].alpha = 0;
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
	if (!isDefined(self.playerCard) || !self.playerCard.size)
		return;

	for (i = 0; i < self.playerCard.size; i++)
		self.playerCard[i] destroy();
	self.playerCard = [];
}
