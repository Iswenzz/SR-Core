end(map)
{
	game["state"] = "endmap";
	level notify("intermission");
	level notify("game over");

	// FX
	setDvar("g_deadChat", 1);
	ambientStop(2);
	visionSetNaked("mp_dr_sm64", 4);
	thread endMusic();
	thread endEarthquake();

	// Clean
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		players[i] closeMenu();
		players[i] closeInGameMenu();
		players[i] freezeControls(true);
		players[i] cleanUp();
		players[i] suicide();
	}
	wait .05;

	// Spectator
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		players[i] spawnSpectator(level.spawn["spectator"].origin, level.spawn["spectator"].angles);
		players[i] allowSpectateTeam("allies", false);
		players[i] allowSpectateTeam("axis", false);
		players[i] allowSpectateTeam("freelook", false);
		players[i] allowSpectateTeam("none", true);
	}
	wait 5;

	playFx(level.fx["endgame"], level.spawn["spectator"].origin - (0, 0, 50));

	// Intermission
	sr\game\_credits::main();
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		players[i] spawnSpectator(level.spawn["spectator"].origin, level.spawn["spectator"].angles);
		players[i].sessionstate = "intermission";
	}
	wait 15;

	// Next map
	maps = sr\commands\game\_vote::load(false);
	picked = IfUndef(map, maps[randomInt(maps.size)]);
	setDvar("sv_maprotationcurrent", "gametype deathrun map " + picked);
	exitLevel(false);
}

endMusic()
{
	wait 1;

	music = fmt("end_map%d", RandomIntRange(2, 11));
	ambientPlay(music, 1);
}

endEarthquake()
{
	while (true)
	{
		earthquake(0.05, 0.05, level.spawn["spectator"].origin, 20000);
		wait 0.05;
	}
}

timer(time, callbackEnd)
{
    level endon("time_update");
	level.time = time;

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
			level.huds.time.color = (1, 140 / 255, 0);
		}
		else if (level.time <= 10)
		{
			clock playSound("ui_mp_timer_countdown");
			level.huds.time.color = (1, 0, 0);
		}
		else if (level.time >= 60)
			level.huds.time.color = (1, 1, 1);
	}
	clock delete();
	level thread [[callbackEnd]]();
}

