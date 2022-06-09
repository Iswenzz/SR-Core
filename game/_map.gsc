#include sr\utils\_common;

main()
{
	level.spawn = [];
	level.colliders = [];
	level.tempEntity = spawn("script_model", (0, 0, 0));

	placeSpawns();
}

placeSpawns()
{
	level.spawn["allies"] = getEntArray("mp_jumper_spawn", "classname");
	level.spawn["axis"] = getEntArray("mp_activator_spawn", "classname");

	if (getEntArray("mp_global_intermission", "classname").size == 0)
	{
		level.spawn["spectator"] = spawn("script_origin", (0, 0, 0));
		level.spawn["spectator"].angles = (0, 0, 0);
	}
	else
		level.spawn["spectator"] = getEntArray("mp_global_intermission", "classname")[0];

	if (!level.spawn["allies"].size)
		level.spawn["allies"] = getEntArray("mp_dm_spawn", "classname");
	if (!level.spawn["axis"].size)
		level.spawn["axis"] = getEntArray("mp_tdm_spawn", "classname");

	for (i = 0; i < level.spawn["allies"].size; i++)
		level.spawn["allies"][i] placeSpawnPoint();

	for (i = 0; i < level.spawn["axis"].size; i++)
		level.spawn["axis"][i] placeSpawnPoint();

	x = 0;
	y = 0;
	z = 0;

	for (i = 0; i < level.spawn["allies"].size; i++)
	{
		x += level.spawn["allies"][i].origin[0];
		y += level.spawn["allies"][i].origin[1];
		x += level.spawn["allies"][i].origin[2];
	}

	x /= level.spawn["allies"].size;
	y /= level.spawn["allies"].size;
	z /= level.spawn["allies"].size;

	level.masterSpawn = spawn("script_origin", (x, y, z));
	level.masterSpawn.angles = level.spawn["allies"][0].angles;
	level.masterSpawn placeSpawnPoint();
}

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
		players[i] spawnSpectator();
		players[i] allowSpectateTeam("allies", false);
		players[i] allowSpectateTeam("axis", false);
		players[i] allowSpectateTeam("freelook", false);
		players[i] allowSpectateTeam("none", true);
	}
	wait 5;

	playFx(level.fx["endgame"], level.spawn["spectator"].origin - (0, 0, 50));

	// Intermission
	sr\game\_credits::start();
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		players[i] spawnSpectator();
		players[i].sessionstate = "intermission";
	}
	wait 15;

	// Next map
	maps = sr\commands\_vote::load(false);
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

spawnSpectator()
{
	self cleanUp();
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.statusicon = "";
	self spawn(level.spawn["spectator"].origin, level.spawn["spectator"].angles);
	self sr\game\_teams::setSpectatePermissions();
}
