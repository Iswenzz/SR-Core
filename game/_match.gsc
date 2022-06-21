#include maps\mp\gametypes\_hud_util;
#include sr\utils\_common;

main()
{
	level.allowSpawn = true;
	level.huds["match"] = [];

	game["roundStarted"] = false;
	game["state"] = "readyup";

	thread huds();
	thread start();
}

start()
{
	level endon("endround");
	level notify("kill logic");
	level endon("kill logic");
	waittillframeend;

	matchStart();

	if (!canStartGame(level.dvar["match_need_players"]))
	{
		level thread start();
		return;
	}

	game["roundsplayed"] = IfUndef(game["roundsplayed"], 1);
	level notify("round_started", game["roundsplayed"]);
	level notify("game started");
	game["state"] = "playing";
	game["roundStarted"] = true;

	matchStartPlayers();
	timer(level.dvar["time"]);
	sr\game\_map::end();
}

canStartGame(min)
{
	count = 0;
	players = getAllPlayers();

	for (i = 0; i < players.size; i++)
	{
		if (players[i] isPlaying())
			count++;
	}
	if (count >= min)
		return true;
	return false;
}

timer(time)
{
	level.time = time;
	level.huds["time"] setTimer(time);

	clock = spawn("script_origin", (0, 0, 0));

	while (level.time > 0)
	{
		wait 1;
		level.time--;

		if (level.time == 180)
			iprintlnbold("^1Map will end in 3 minutes!");
		else if (level.time <= 60 && level.time > 10 && level.time % 2 == 0)
		{
			clock playSound("ui_mp_timer_countdown");
			level.huds["time"].color = (1, 0.55, 0);
		}
		else if (level.time <= 10)
		{
			clock playSound("ui_mp_timer_countdown");
			level.huds["time"].color = (1, 0, 0);
		}
		else if (level.time >= 60)
			level.huds["time"].color = (1, 1, 1);
	}
	clock delete();
	level.huds["time"] destroy();
}

huds()
{
	level.huds["time"] = newHudElem();
	level.huds["time"].foreground = true;
	level.huds["time"].alignX = "right";
	level.huds["time"].alignY = "bottom";
	level.huds["time"].horzAlign = "right";
	level.huds["time"].vertAlign = "bottom";
	level.huds["time"].x = -10;
	level.huds["time"].y = -2;
	level.huds["time"].sort = 0;
	level.huds["time"].fontScale = 1.4;
	level.huds["time"].color = (1, 1, 1);
	level.huds["time"].font = "objective";
	level.huds["time"].hidewheninmenu = true;
	level.huds["time"].label = &"^7&&1";
	level.huds["time"].alpha = 1;
	level.huds["time"].archived = false;
}

matchStart()
{
	level endon("endround");

	visionSetNaked("mpIntro", 0);
	if (isDefined(level.huds["match"]["text"]))
		level.huds["match"]["text"] destroyElem();

	wait 0.2;

	level.huds["match"]["text"] = createServerFontString("objective", 1.5);
	level.huds["match"]["text"] setPoint("CENTER", "CENTER", 0, -20);
	level.huds["match"]["text"].sort = 1001;
	level.huds["match"]["text"] setText(level.texts["waiting_for_players"]);
	level.huds["match"]["text"].foreground = false;
	level.huds["match"]["text"].hidewheninmenu = true;

	roundStartTimer();
}

matchStartPlayers()
{
	visionSetNaked(toLower(level.map), 2.0);

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		if (players[i] isPlaying())
		{
			players[i] freezeControls(0);
			players[i] unLink();
			players[i] enableWeapons();
		}
	}
}

roundStartTimer()
{
	if (isDefined(level.huds["match"]["text"]))
		level.huds["match"]["text"] destroyElem();

	level.huds["match"]["text"] = createServerFontString("objective", 1.5);
	level.huds["match"]["text"] setPoint("CENTER", "CENTER", 0, -20);
	level.huds["match"]["text"].sort = 1001;
	level.huds["match"]["text"] setText(level.texts["round_begins_in"]);
	level.huds["match"]["text"].foreground = false;
	level.huds["match"]["text"].hidewheninmenu = true;

	level.huds["match"]["timer"] = createServerTimer("objective", 1.4);
	level.huds["match"]["timer"] setPoint("CENTER", "CENTER", 0, 0);
	level.huds["match"]["timer"] setTimer(level.dvar["spawn_time"]);
	level.huds["match"]["timer"].sort = 1001;
	level.huds["match"]["timer"].foreground = false;
	level.huds["match"]["timer"].hideWhenInMenu = true;

	wait level.dvar["spawn_time"];

	level.huds["match"]["text"] destroyElem();
	level.huds["match"]["timer"] destroyElem();
}
