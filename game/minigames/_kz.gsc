#include sr\sys\_file;
#include sr\sys\_events;
#include sr\game\minigames\_main;
#include sr\utils\_common;

initKz()
{
	level.files["kz"] = fmt("sr/data/kz/%s.txt", level.map);

	createMinigame("kz");

	level.kzPoints = [];
	level.kzPlayersInRoom = [];
	level.kzRandomPoints = [];
	level.kzWeapon = "m40a3_mp";
	level.kzWeaponMode = "rng";
	level.kzWeaponList = strTok("m40a3_mp,g3_reflex_mp,m1014_mp,m14_mp,ak47_mp,mp5_acog_mp,ak47_gl_mp,g36c_silencer_mp,m1014_grip_mp,mp5_mp,gl_m14_mp,m60e4_mp,dragunov_mp,p90_acog_mp,rpg_mp,", ",");
	level.kzStarted = false;

	event("killed", ::onPlayerKilled);
	event("damage", ::onPlayerDamage);
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
		
		wait 1;
		if (!canStart())
			continue;

		level.kzPlayersInRoom = [];
		level.kzRandomPoints = [];

		gameRandomize();
		sendPlayers();
		watchGame();
	}
}

hud()
{
	if (!isInQueue("kz"))
		return;

	self waittill("speedrun_hud");
	self.runId = "KZ";
	self.huds["speedrun"]["name"] setText("^1Kill Zone");
	self.huds["speedrun"]["row2"] setText(fmt("Health             ^2%d", self.health));
	self.huds["speedrun"]["row3"] setText(fmt("K/D                    ^3%d/%d", self.kills, self.deaths));
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
	self addToQueue("kz");

	self sr\sys\_admins::message(fmt("%s ^7joined the killzone! [^6!killzone^7] [^1%d^7]",
		self.name, level.minigames["kz"].queue.size));
}

leave()
{
	level.kzPlayersInRoom = Remove(level.kzPlayersInRoom, self);
	self removeFromQueue("kz");
	self setClientDvar("cg_drawFriendlyNames", 1);
	self unlink();
	self sr\game\_teams::setTeam("allies");
	self.kzWon = false;
	self.teamKill = undefined;

	self sr\sys\_admins::pm("You left the killzone!");
	self suicide();
}

onPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	if (!self isInQueue("kz") || !level.kzStarted || !isAlive(self))
		return;
		
	self.huds["speedrun"]["row2"] setText(fmt("Health             ^2%d", self.health - iDamage));
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	if (!self isInQueue("kz") || !level.kzStarted)
		return;

	if (attacker != self && isPlayer(attacker))
	{
		attacker.kzWon = true;
		attacker.kills++;
		attacker.pers["kills"]++;
		sr\game\_rank::processXpReward(sMeansOfDeath, attacker, self);

		if (isAlive(attacker))
		{
			attacker.huds["speedrun"]["row3"] setText(fmt("K/D                    ^3%d/%d", 
				attacker.kills, attacker.deaths));
			attacker.time = sr\utils\_common::originToTime(getTime() - attacker.time.origin);
			attacker speedrun\player\huds\_speedrun::updateTime();
		}
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
		level.minigames["kz"].queue[i] spawnPlayerInSpec();
	for (i = 0; i < level.kzPlayersInRoom.size; i++)
		level.kzPlayersInRoom[i] thread spawnPlayerInRoom(i);
}

spawnPlayerInRoom(spawnIndex)
{
	self endon("disconnect");

	self.teamKill = true;
	self.kzWon = false;
	self sr\game\_teams::setTeam("axis");

	self eventSpawn(true, level.kzRandomPoints[spawnIndex]);
	self takeAllWeapons();
	self giveWeapon(level.kzWeapon);
	self giveMaxAmmo(level.kzWeapon);
	wait 0.05;
	self switchToWeapon(level.kzWeapon);
	self setClientDvar("cg_drawFriendlyNames", 0);
	self thread sr\player\huds\_card::hud(level.kzPlayersInRoom[0], level.kzPlayersInRoom[1]);
}

spawnPlayerInSpec()
{
	self endon("disconnect");
	self.teamKill = undefined;
	self sr\game\_teams::setTeam("spectator");
	self eventSpectator(true);
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

		level.kzStarted = false;
		level notify("kz ended");
	}
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
