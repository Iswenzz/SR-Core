#include maps\mp\_utility;
#include sr\sys\_file;
#include sr\game\minigames\_main;
#include sr\utils\_common;
#include sr\utils\_hud;

init()
{
	level.file.kz = fmt("sr/data/race/%s.txt", getDvar("mapname"));

	createMinigame("race");

	level.racePoints = [];
	level.raceSpawn = level.masterspawn;
	level.raceEndTrig = getEnt("endmap_trig", "targetname");
	level.minigames["race"].queue = [];
	level.racePlayersFinished = [];
	level.raceScoreboard = [];
	level.racePoints = [];
	level.raceStarted = false;

	race();
}

race()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");

	load();

	while (true)
	{
		level.raceStarted = false;
		ForEachThread(level.minigames["race"].queue, ::cleanRaceHud);

		if (!canStart())
		{
			wait 1;
			continue;
		}
		sr\sys\_admins::message("^3Race start in 10sec! ^7[^2!race^7]");
		wait 10;

		ForEachThread(level.minigames["race"].queue, ::spawnPlayer);
		countdown();

		level.raceStarted = true;
		ForEachThread(level.minigames["race"].queue, ::raceHud);
		watchRace();

		sr\sys\_admins::message("^3Race lobby is open! ^7[^2!race^7]");
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
		if (tkn.size < 3)
			continue;

		origin = (ToFloat(tkn[0]), ToFloat(tkn[1]), ToFloat(tkn[2]));
		level.kzPoints[level.kzPoints.size] = origin;
	}
	FILE_Close(file);
}

join()
{
	self addToQueue("race");
	self addToScoreboard();
	self.sr_cheatmode = true;

	sr\sys\_admins::message("%s ^7joined the race! [^2!race^7] [^1%d^7]", self.name, level.minigames["race"].queue.size);
}

leave()
{
	self endon("disconnect");

	self.inRace = false;
	self removeFromQueue("race");
	self cleanRaceHud();

	self unlink();
	self suicide();
	self.sr_cheatmode = false;
}

countdown()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");

	for (i = 10; i != 0; i--)
	{
		wait 1;
		ForEachCall(level.minigames["race"].queue, ::setLowerMessage, i - 1);
		if (i == 7)
			ForEachCall(level.minigames["race"].queue, ::playerFreeze);
	}
	wait 1;
	ForEachThread(level.minigames["race"].queue, ::go);
}

playerFreeze()
{
	self endon("disconnect");

	self freezeControls(false);
	self setVelocity((0, 0, 0));
	self setOrigin(level.raceSpawn.origin);
	self setPlayerAngles(level.raceSpawn.angles);
	self linkTo(level.tempEntity);
}

go()
{
	self unlink();
	self clearLowerMessage();
	self iPrintLnBold("^3GO!");
	if (isDefined(self.huds.speedrun[4]))
		self.huds.speedrun[4] setTenthsTimerUp(0.0001);
	self.raceTime = getTime();
	self thread onDeath();
}

onDeath()
{
	self endon("disconnect");
	self notify("race die reset");
	self endon("race die reset");

	self waittill("death");
	self iPrintLn("^1You died, wait till the race end.");
	self.raceDead = true;
	self setVelocity((0, 0, 0));
	ori = self getOrigin();
	self setOrigin((ori[0], ori[1], ori[2] + 100));
	self linkTo(level.tempEntity);
}

spawnPlayer()
{
	self endon("disconnect");

	self.inRace = true;
	self.raceDead = false;
	self.raceFinish = false;
	self suicide();
	self braxi\_mod::respawn();
	self freezeControls(true);

	wait 0.3;
	if (isDefined(self.huds.speedrun[4]))
		self.huds.speedrun[4] setText("^50:00.0");
}

updateScoreHud()
{
	level endon("game over");
	level endon("intermission");

	self.raceWon++;

	// Update
	players = level.minigame["race"].queue;
	for (p = 0; p < players.size; p++)
	{
		for (i = 0; i < level.raceScoreboard.size; i++)
		{
			if (level.raceScoreboard[i]["id"] == players[p].id)
				level.raceScoreboard[i]["score"] = players[p].raceWon;
		}
	}
	level.raceScoreboard = sortScores(level.raceScoreboard);

	// Hud
	string = "^7[Race Score]\n";
	for (i = 0; i < level.raceScoreboard.size && i <= 5; i++)
	{
		string += fmt("%s[%d] %s\n", getPositionColorString(i + 1),
			level.raceScoreboard[i]["score"], level.raceScoreboard[i]["name"]);
	}
	for (i = 0; i < players.size; i++)
		players[i].raceScoreHud setText(string);
}

sortScores(array)
{
	temp = 0;
	for (i = 0; i < array.size; i++)
	{
		for (j = i + 1; j < array.size; j++)
		{
			if (array[j]["score"] < array[i]["score"])
			{
				temp = array[i];
				array[i] = array[j];
				array[j] = temp;
			}
		}
	}
	return Reverse(array);
}

raceHud()
{
	self.raceHud = addHud(self, 18, -15, 1, "left", "bottom", 4);
	if (!isDefined(self.raceScoreHud))
		self.raceScoreHud = addHud(self, -2, -20, 1, "right", "middle", 1.4);
}

cleanRaceHud()
{
	if (isDefined(self.raceHud))
		self.raceHud destroy();
	if (isDefined(self.raceScoreHud))
		self.raceScoreHud destroy();
}

addToScoreboard()
{
	for (i = 0; i < level.raceScoreboard.size; i++)
	{
		if (level.raceScoreboard[i]["id"] == self.id)
			return;
	}
	entry = [];
	entry["name"] = self.name;
	entry["score"] = self.raceWon;
	entry["id"] = self.id;

	level.raceScoreboard[level.raceScoreboard.size] = entry;
}

canStart()
{
	if (!isDefined(level.raceEndTrig))
	{
		iPrintLn("^1RACE ERROR: Race end trig not found.");
		ForEach(level.minigames["race"].queue, ::cleanRaceHud);
		ForEach(level.minigames["race"].queue, ::leave);
		return false;
	}
	if (level.racePoints.size <= 0)
	{
		iPrintLn("^1RACE ERROR: Race points not found.");
		ForEach(level.minigames["race"].queue, ::cleanRaceHud);
		ForEach(level.minigames["race"].queue, ::leave);
		return false;
	}
	if (level.minigames["race"].queue.size < 2)
		return false;
	return true;
}

watchRaceEndTrig()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level endon("race ended");

	while (true)
	{
		level.raceEndTrig waittill("trigger", player);
		if (!player.raceFinish)
			player thread playerFinish();
	}
}

watchAllDied()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level endon("race ended");

	while (Any(level.minigames["race"].queue, ::isRacing))
		wait 1;

	level notify("race ended");
}

watchEnd()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level endon("race ended");

	startEndCountdown = false;
	while (true)
	{
		level.raceEndTrig waittill("trigger");
		if (!startEndCountdown)
		{
			startEndCountdown = true;
			thread countdownStop();
		}
		if (level.minigames["race"].queue.size == level.racePlayersFinished.size)
			level notify("race ended");
	}
}

playerFinish()
{
	self endon("disconnect");
	placement = level.racePlayersFinished.size + 1;

	self.raceFinish = true;
	if (isDefined(self.raceHud))
		self.raceHud destroy();
	self linkTo(level.tempEntity);

	if (self IsInArray(level.racePlayersFinished))
		return;
	level.racePlayersFinished[level.racePlayersFinished.size] = self;

	self.time = sr\utils\_common::originToTime(getTime() - self.raceTime.origin);
	self thread speedrun\player\huds\_speedrun::updateHud();

	message(fmt("%s ^7finished %s ^7in ^2%d:%d.%d", self.name, getPlacementString(placement),
		self.time.min, self.time.sec, self.time.milsed));

	if (placement == 1)
		self updateScoreHud();
}

message(string)
{
	players = level.minigames["race"].queue;
	for (i = 0; i < players.size; i++)
		players[i] iPrintLnBold(string);
}

countdownStop()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level endon("race ended");

	wait 5;
	sr\sys\_admins::message("^3Race end in 30secs!");

	wait 30;
	level notify("race ended");
}

watchLobbyCount()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level endon("race ended");

	while (Count(level.minigames["race"].queue, ::isInRace) >= 2)
		wait 1;

	ForEachThread(level.minigames["race"].queue, ::cleanRaceHud);
	ForEachThread(level.minigames["race"].queue, ::leave);
	level.raceScoreboard = [];
	level notify("race ended");
}

isInRace(player, index)
{
	return player.inRace;
}

isRacing(player, index)
{
	return !player.raceDead && !player.raceFinish;
}

watchTimer()
{
	level endon("race ended");
	wait 180;
	level notify("race ended");
}

watchRace()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");
	level notify("race ended");
	level endon("race ended");

	for (i = 0; i < level.minigames["race"].queue.size; i++)
		level.minigames["race"].queue[i].closestPoint = 0;

	level.racePlayersFinished = [];

	thread watchTimer();
	thread watchRaceEndTrig();
	thread watchAllDied();
	thread watchLobbyCount();
	thread watchEnd();

	queue = level.minigames["race"].queue;

	while (true)
	{
		// Get players closest point
		for (i = 0; i < queue.size; i++)
		{
			for (z = 0; z < level.racePoints.size; z++)
			{
				newDist = distance2D(queue[i] getOrigin(), level.racePoints[z]);
				oldDist = distance2D(queue[i] getOrigin(), level.racePoints[queue.closestPoint]);

				if (newDist < oldDist)
					queue.closestPoint = z;
			}
		}

		// See who is closest to the highest point
		idx = 0;
		level.racePlayersOrder = [];
		for (z = level.racePoints.size; z >= 0; z--)
		{
			for (i = 0; i < queue.size; i++)
			{
				if (queue[i].closestPoint == z)
				{
					level.racePlayersOrder[idx] = queue[i];
					idx++;
				}
			}
		}

		// Check if multiple players have the same highest point
		temp = 0;
		for (t = 0; t < level.racePlayersOrder.size; t++)
		{
			for (i = 0; i < level.racePlayersOrder.size - 1; i++)
			{
				if (level.racePlayersOrder[i].closestPoint == level.racePlayersOrder[i + 1].closestPoint)
				{
					dist1 = undefined;
					dist2 = undefined;

					if (isDefined(level.racePoints[level.racePlayersOrder[i].closestPoint + 1]))
						dist1 = distance2D(level.racePlayersOrder[i] getOrigin(),
							level.racePoints[level.racePlayersOrder[i].closestPoint + 1]);
					if (isDefined(level.racePoints[level.racePlayersOrder[i + 1].closestPoint + 1]))
						dist2 = distance2D(level.racePlayersOrder[i + 1] getOrigin(),
							level.racePoints[level.racePlayersOrder[i + 1].closestPoint + 1]);

					if (isDefined(dist1) && isDefined(dist2) && dist1 > dist2)
					{
						temp = level.racePlayersOrder[i + 1];
						level.racePlayersOrder[i + 1] = level.racePlayersOrder[i];
						level.racePlayersOrder[i] = temp;
					}
				}
			}
		}
		ForEach(level.racePlayersOrder, ::updateRaceHud);
		wait 0.1;
	}
}

updateRaceHud(player, index)
{
	player.raceHud setText(getPlacementString(index + 1));
}

getPlacementString(index)
{
	switch (index)
	{
		case 1: 	return "^31st";
		case 2: 	return "^82nd";
		case 3: 	return "^93rd";
		default: 	return "^7" + index + "th";
	}
}

getPositionColorString(index)
{
	switch (index)
	{
		case 1:		return "^3";
		case 2:		return "^8";
		case 3:		return "^9";
		default:	return "^7";
	}
}
