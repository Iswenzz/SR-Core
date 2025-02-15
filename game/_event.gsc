#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

start()
{
	event("spawn", ::onSpawn);
	event("death", ::onDeath);

	sr\game\_map::addTime(30);

	level endon("end map");
	level endon("game over");
	level endon("intermission");

	level.eventInitialized = true;
	level.eventStarted = false;
	level.eventStartIn = 30;
	level.eventGame = 0;
	level.eventGames = 5;
	level.eventGameTitle = "Event";
	level.eventRounds = 6;
	level.eventRound = 0;
	level.eventWave = 1;

	hud();

	iPrintLnBold("^2Event started!");
	level notify("event_start");
	level.eventStarted = true;
	level.allowSpawn = false;

	while (level.eventGame < level.eventGames)
		level waittill("event_game_end");

	iPrintLnBold("^2Event ended!");
	level notify("event_end");
	level.eventInitialized = undefined;
	level.allowSpawn = true;

	foreachCall(getAllPlayers(), ::playerEventEnd);
}

startGame(title, spawnPoint, messages, resetRoundCallback, startRoundCallback)
{
	if (level.eventGame >= level.eventGames)
		return;

	level endon("event_game_end");
	level notify("event_game");

	foreachCall(getAllPlayers(), ::playerEventGame);

	level.eventRound = 0;
	level.eventWave = 1;
	level.eventGameTitle = title;

	while (level.eventRound < level.eventRounds)
	{
		[[resetRoundCallback]]();
		foreachCall(getAllPlayers(), ::playerSpawnAt, spawnPoint);

		cleanScreen();
		thread hudIntro(title, messages);
		wait 1;

		for (i = 0; i < messages.size; i++)
		{
			iPrintLnBold(messages[i]);
			wait 5;
		}
		wait 5;
		iPrintLnBold("^2Round started!");
		wait 3;
		level notify("event_round");
		thread [[startRoundCallback]]();

		level waittill("event_round_end");
		level.eventRound++;
		wait 5;
	}
	[[resetRoundCallback]]();
	level.eventGame++;

	hudScoreboard();
	wait 5;

	level notify("event_game_end");
}

playerEventGame()
{
	self sr\player\modes\_main::cleanModes();
	self playerResetScore();
}

playerEventEnd()
{
	self.playerSpawn = undefined;
	self playerResetScore();
	self suicide();
}

playerSpawnAt(entity)
{
	self.playerSpawn = entity;
	self eventSpawn(true);
}

playerAddPoints(points)
{
	self.kills += points;
	self.pers["kills"] += points;
	self sr\game\_rank::giveRankXP("", points * 2000);

	if (isDefined(self.huds["speedrun"]) && isDefined(self.huds["speedrun"]["row3"]))
		self.huds["speedrun"]["row3"] setText(fmt("Points             ^2%d", self.pers["kills"]));
}

playerResetScore()
{
	self.kills = 0;
	self.pers["kills"] = 0;

	self.deaths = 0;
	self.pers["deaths"] = 0;
}

hud()
{
	time = level.eventStartIn;

	level.huds["event"]["text"] = addHud(level, 0, 70, 1, "center", "middle", 1.6, 1000, true);
	level.huds["event"]["text"] setText("^2Event starts in");
	level.huds["event"]["timer"] = addHud(level, 0, 90, 1, "center", "middle", 1.4, 1000, true);
	level.huds["event"]["timer"] setTimer(time);

	while (time)
	{
		wait 1;
		time--;
	}
	level.huds["event"]["text"] destroy();
	level.huds["event"]["timer"] destroy();
}

hudIntro(title, messages)
{
	level endon("event_game");

	time = messages.size * 7;

	if (isDefined(level.huds["event"]["title"]))
		level.huds["event"]["title"] destroy();
	if (isDefined(level.huds["event"]["background"]))
		level.huds["event"]["background"] destroy();
	if (isDefined(level.huds["event"]["header"]))
		level.huds["event"]["header"] destroy();

	level.huds["event"]["title"] = addHud(level, 0, 82, 1, "center", "top", 1.4, 96);
	level.huds["event"]["title"] setText(title);
	level.huds["event"]["title"] thread moveIn(0, 1, "bottom", 1);

    level.huds["event"]["background"] = addHud(level, 0, 80, 1, "center", "top", 1.8);
    level.huds["event"]["background"].color = (0, 0, 0);
    level.huds["event"]["background"] setShader("sr_bokeh_multiply", 500, 150);
    level.huds["event"]["background"] thread moveIn(0, 1, "bottom", 1);

    level.huds["event"]["header"] = addHud(level, 0, 80, 0.5, "center", "top", 1.8);
    level.huds["event"]["header"] setShader("black", 500, 20);
    level.huds["event"]["header"] thread moveIn(0, 1, "bottom", 1);

	wait time;

	level.huds["event"]["title"] thread moveOut(0, 1, "top", 1, true);
	level.huds["event"]["background"] thread moveOut(0, 1, "top", 1, true);
	level.huds["event"]["header"] thread moveOut(0, 1, "top", 1, true);
}

hudScoreboard()
{
	if (isDefined(level.huds["event"]["title"]))
		level.huds["event"]["title"] destroy();
	if (isDefined(level.huds["event"]["scoreboard"]))
		level.huds["event"]["scoreboard"] destroy();
	if (isDefined(level.huds["event"]["background"]))
		level.huds["event"]["background"] destroy();
	if (isDefined(level.huds["event"]["header"]))
		level.huds["event"]["header"] destroy();

	players = sortPlayersByKills();
	scores = "";
	for (i = 0; i < players.size && i < 10; i++)
	{
		color = "^7";
		switch (i)
		{
			case 0: color = "^3"; break;
			case 1: color = "^8"; break;
			case 2: color = "^9"; break;
		}
		scores += fmt("%s#%d (%d) %s\n", color, i + 1, players[i].pers["kills"], players[i].name);
	}

	level.huds["event"]["title"] = addHud(level, 0, 82, 1, "center", "top", 1.4, 96);
	level.huds["event"]["title"] setText("Scoreboard");
	level.huds["event"]["title"] thread moveIn(0, 1, "bottom", 1);

	level.huds["event"]["scoreboard"] = addHud(level, -80, 110, 1, "center", "top", 1.4, 96);
	level.huds["event"]["scoreboard"] setText(scores);
	level.huds["event"]["scoreboard"] thread moveIn(0, 1, "bottom", 1);

    level.huds["event"]["background"] = addHud(level, 0, 80, 1, "center", "top", 1.8);
    level.huds["event"]["background"].color = (0, 0, 0);
    level.huds["event"]["background"] setShader("sr_bokeh_multiply", 300, 210);
    level.huds["event"]["background"] thread moveIn(0, 1, "bottom", 1);

    level.huds["event"]["header"] = addHud(level, 0, 80, 0.5, "center", "top", 1.8);
    level.huds["event"]["header"] setShader("black", 300, 20);
    level.huds["event"]["header"] thread moveIn(0, 1, "bottom", 1);

	wait 10;

	level.huds["event"]["title"] thread moveOut(0, 1, "top", 1, true);
	level.huds["event"]["scoreboard"] thread moveOut(0, 1, "top", 1, true);
	level.huds["event"]["background"] thread moveOut(0, 1, "top", 1, true);
	level.huds["event"]["header"] thread moveOut(0, 1, "top", 1, true);
}

sortPlayersByKills()
{
    players = getAllPlayers();
    for (i = 0; i < players.size - 1; i++)
    {
        for (j = 0; j < players.size - i - 1; j++)
        {
            if (players[j].pers["kills"] < players[j + 1].pers["kills"])
            {
                temp = players[j];
                players[j] = players[j + 1];
                players[j + 1] = temp;
            }
        }
    }
    return players;
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!isEventStarted())
		return;

	if (isDefined(self.huds["speedrun"]))
	{
		self.huds["speedrun"]["name"] setText(fmt("^5%s", level.eventGameTitle));
		self.huds["speedrun"]["row2"] setText(fmt("Round             ^2%d/%d", level.eventRound + 1, level.eventRounds));
		self.huds["speedrun"]["row2"].label = level.texts["empty"];
		self.huds["speedrun"]["row3"] setText(fmt("Points             ^2%d", self.pers["kills"]));
		self.huds["speedrun"]["row3"].label = level.texts["empty"];
	}
}

onDeath()
{
	self endon("spawned");
	self endon("disconnect");

	if (!isEventStarted())
		return;

	self.deaths++;
	self.pers["deaths"]++;

	self sr\game\_teams::setDead();
	self sr\game\_teams::setSpectatePermissions();
	self eventSpectator(true);
}

isEvent()
{
	return isDefined(level.eventInitialized);
}

isEventStarted()
{
	return isEvent() && level.eventStarted;
}

isEventGame(number)
{
	return isEventStarted() && level.eventGame == number;
}

registerEventMap()
{
	level.eventMap = true;
}
