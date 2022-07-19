#include sr\sys\_file;
#include sr\sys\_events;
#include sr\game\minigames\_main;
#include sr\utils\_common;
#include sr\utils\_hud;

initRace()
{
	level.files["race"] = fmt(PATH_Mod("sr/data/race/%s.txt"), level.map);

	createMinigame("race");

	level.racePoints = [];
	level.raceSpawn = level.masterspawn;
	level.raceEndTrig = getEnt("endmap_trig", "targetname");
	level.racePlayersFinished = [];
	level.raceScoreboard = [];
	level.racePoints = [];
	level.raceStarted = false;

	event("spawn", ::hud);
	event("death", ::death);

	thread race();
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

		wait 1;
		if (!canStart())
			continue;

		sr\sys\_admins::message("^3Race start in 10sec! ^7[^2!race^7]");
		ForEachCall(level.minigames["race"].queue, ::cleanRaceHud);
		ForEachThread(level.minigames["race"].queue, ::spawnPlayer);
		countdown();

		level.raceStarted = true;
		ForEachThread(level.minigames["race"].queue, ::raceHud);
		watchRace();
	}
}

hud()
{
	if (!isInQueue("race"))
		return;

	self waittill("speedrun_hud");
	self.run = "Race";
	self.huds["speedrun"]["name"] setText("^2Race");
}

load()
{
	if (!FILE_Exists(level.files["race"]))
		return;

	file = FILE_Open(level.files["race"], "r+");

	while (true)
	{
		line = FILE_ReadLine(file);
		tkn = strTok(line, "/");

		if (IsNullOrEmpty(line) || tkn.size < 3)
			break;

		origin = (ToFloat(tkn[0]), ToFloat(tkn[1]), ToFloat(tkn[2]));
		level.racePoints[level.racePoints.size] = origin;
	}
	FILE_Close(file);
}

join()
{
	if (level.raceStarted)
	{
		sr\sys\_admins::pm("^3Race already started!");
		return;
	}
	self addToQueue("race");
	self addToScoreboard();
	self.raceWon = 0;

	sr\sys\_admins::message(fmt("%s ^7joined the race! [^2!race^7] [^1%d^7]", self.name, level.minigames["race"].queue.size));
}

leave()
{
	self removeFromQueue("race");
	self cleanRaceHud();
	self unlink();
	self sr\game\_teams::setTeam("allies");
	self.inRace = false;

	self sr\sys\_admins::pm("You left the race!");
	self suicide();
}

countdown()
{
	level endon("end map");
	level endon("game over");
	level endon("intermission");

	for (i = 10; i != 0; i--)
	{
		wait 1;
		ForEachCall(level.minigames["race"].queue, ::setLowerMessage, Ternary(i == 1, "^3GO", i - 1));
		if (i == 7)
			ForEachCall(level.minigames["race"].queue, ::playerFreeze);
	}
	ForEachThread(level.minigames["race"].queue, ::go);
}

playerFreeze()
{
	self endon("disconnect");

	self setVelocity((0, 0, 0));
	self setOrigin(level.raceSpawn.origin);
	self setPlayerAngles(level.raceSpawn.angles);
	self linkTo(level.tempEntity);
	self freezeControls(false);
}

go()
{
	self unlink();
	self clearLowerMessage();
	self.huds["speedrun"]["row1"] setTenthsTimerUp(0.0001);
	self.raceTime = getTime();
}

death()
{
	if (!self isInQueue("race") || !level.raceStarted)
		return;

	self.raceDead = true;
}

spawnPlayer()
{
	self endon("disconnect");

	self sr\game\_teams::setTeam("axis");
	self suicide();
	self eventSpawn(true);

	self.inRace = true;
	self.raceDead = false;
	self.raceFinish = false;
	self.huds["speedrun"]["row1"] setText("^50:00.0");
}

updateScoreHud()
{
	level endon("game over");
	level endon("intermission");

	self.raceWon++;

	// Update
	players = level.minigames["race"].queue;
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
		players[i].huds["race_score"] setText(string);
}

sortScores(array)
{
	for (i = 0; i < array.size; i++)
	{
		for (z = 0; z < array.size - 1; z++)
		{
			if (array[z]["score"] < array[z + 1]["score"])
			{
				swap = array[z + 1];
				array[z + 1] = array[z];
				array[z] = swap;
			}
		}
	}
	return array;
}

raceHud()
{
	self.huds["race"] = addHud(self, 18, -15, 1, "left", "bottom", 4);
	if (!isDefined(self.huds["race_score"]))
		self.huds["race_score"] = addHud(self, -2, -20, 1, "right", "middle", 1.4);
}

cleanRaceHud()
{
	if (isDefined(self.huds["race"]))
		self.huds["race"] destroy();
	if (isDefined(self.huds["race_score"]))
		self.huds["race_score"] destroy();
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
	if (level.minigames["race"].queue.size < 2)
		return false;
	if (!isDefined(level.raceEndTrig))
	{
		iPrintLn("^1RACE ERROR: Race end trig not found.");
		ForEachThread(level.minigames["race"].queue, ::cleanRaceHud);
		ForEachThread(level.minigames["race"].queue, ::leave);
		return false;
	}
	if (level.racePoints.size <= 0)
	{
		iPrintLn("^1RACE ERROR: Race points not found.");
		ForEachThread(level.minigames["race"].queue, ::cleanRaceHud);
		ForEachThread(level.minigames["race"].queue, ::leave);
		return false;
	}
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

	while (Count(level.minigames["race"].queue, ::isRacing) >= 2)
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
	if (isDefined(self.huds["race"]))
		self.huds["race"] destroy();
	self linkTo(level.tempEntity);

	if (Contains(level.racePlayersFinished, self))
		return;
	level.racePlayersFinished[level.racePlayersFinished.size] = self;

	self.time = originToTime(getTime() - self.raceTime);
	self speedrun\player\huds\_speedrun::updateTime();

	playerMessage(fmt("%s ^7finished %s ^7in ^2%d:%d.%d", self.name, getPlacementString(placement),
		self.time.min, self.time.sec, self.time.ms));

	if (placement == 1)
		self updateScoreHud();
}

playerMessage(string)
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
	return isDefined(player) && player.inRace;
}

isRacing(player, index)
{
	return !player.raceDead;
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

	while (true)
	{
		// Get players closest point
		queue = level.minigames["race"].queue;
		for (i = 0; i < queue.size; i++)
		{
			for (z = 0; z < level.racePoints.size; z++)
			{
				if (!isInRace(queue[i]))
					continue;

				newDist = distance2D(queue[i] getOrigin(), level.racePoints[z]);
				oldDist = distance2D(queue[i] getOrigin(), level.racePoints[queue[i].closestPoint]);

				if (newDist < oldDist)
					queue[i].closestPoint = z;
			}
		}

		// See who is closest to the highest point
		idx = 0;
		order = [];
		queue = level.minigames["race"].queue;
		for (z = level.racePoints.size; z >= 0; z--)
		{
			for (i = 0; i < queue.size; i++)
			{
				if (isInRace(queue[i]) && queue[i].closestPoint == z)
				{
					order[idx] = queue[i];
					idx++;
				}
			}
		}

		// Check if multiple players have the same highest point
		temp = 0;
		for (t = 0; t < order.size; t++)
		{
			for (i = 0; i < order.size - 1; i++)
			{
				if (isInRace(order[i]) && order[i].closestPoint == order[i + 1].closestPoint)
				{
					dist1 = undefined;
					dist2 = undefined;

					if (isDefined(level.racePoints[order[i].closestPoint + 1]))
						dist1 = distance2D(order[i] getOrigin(),
							level.racePoints[order[i].closestPoint + 1]);
					if (isDefined(level.racePoints[order[i + 1].closestPoint + 1]))
						dist2 = distance2D(order[i + 1] getOrigin(),
							level.racePoints[order[i + 1].closestPoint + 1]);

					if (isDefined(dist1) && isDefined(dist2) && dist1 > dist2)
					{
						temp = order[i + 1];
						order[i + 1] = order[i];
						order[i] = temp;
					}
				}
			}
		}
		ForEach(order, ::updateRaceHud);
		wait 0.1;
	}
}

updateRaceHud(player, index)
{
	if (isDefined(player.huds["race"]))
		player.huds["race"] setText(getPlacementString(index + 1));
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
