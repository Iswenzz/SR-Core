#include sr\sys\_events;
#include sr\sys\_file;
#include sr\utils\_common;

main()
{
	level.spawn = [];
	level.colliders = [];
	level.tempEntity = spawn("script_model", (0, 0, 0));
	level.files["rotation"] = PATH_Mod("sr/data/match/rotation.txt");
	level.rotation = getRotation(false);
	level.randomizedMaps = [];

	placeSpawns();
	thread randomizeMaps(5);
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

	angles = (0, 180, 0);

	for (i = 0; i < level.spawn["allies"].size; i++)
	{
		x += level.spawn["allies"][i].origin[0];
		y += level.spawn["allies"][i].origin[1];
	}
	if (level.spawn["allies"].size)
	{
		x /= level.spawn["allies"].size;
		y /= level.spawn["allies"].size;
		z = level.spawn["allies"][0].origin[2];

		angles = level.spawn["allies"][0].angles;
	}

	level.masterSpawn = spawn("script_origin", (x, y, z));
	level.masterSpawn.angles = angles;
	level.masterSpawn placeSpawnPoint();
}

end(map)
{
	game["state"] = "endmap";
	level notify("intermission");
	level notify("game over");

	// Sequence
	endEffect();
	endSpectate();
	displayMapScores();

	if (IsNullOrEmpty(map))
		map = voteNextMap();

	credits();
	intermission();

	// Next map
	setDvar("sv_maprotationcurrent", "gametype deathrun map " + map);
	exitLevel(false);
}

endEffect()
{
	playFx(level.fx["endgame"], level.spawn["spectator"].origin - (0, 0, 50));
	setDvar("g_deadChat", 1);
	ambientStop(2);
	visionSetNaked("mp_dr_sm64", 4);
	thread endMusic();
	thread endEarthquake();
}

endSpectate()
{
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

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		players[i] spawnSpectator();
		players[i] allowSpectateTeam("allies", false);
		players[i] allowSpectateTeam("axis", false);
		players[i] allowSpectateTeam("freelook", false);
		players[i] allowSpectateTeam("none", true);
	}
	wait 3;
}

displayMapScores()
{
	if (!level.dvar["map_scores"])
		return;
}

voteNextMap()
{
	maps = level.randomizedMaps;

	if (level.dvar["map_vote"])
		return menuVote(maps);
	return maps[randomInt(maps.size)];
}

credits()
{
	sr\game\_credits::start();
	wait 3;
}

intermission()
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		players[i] spawnSpectator();
		players[i].sessionstate = "intermission";
	}
	wait 10;
}

menuVote(maps)
{

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

randomizeMaps(amount)
{
	maps = [];
	rotation = level.rotation;
	file = FILE_Open(level.files["rotation"], "a+");
	playedMaps = FILE_ReadLines(file);

	if (rotation.size < amount)
		return;

	// No more new maps found
	if (playedMaps.size >= rotation.size - amount)
	{
		FILE_Close(file);
		FILE_Delete(level.files["rotation"]);
		return thread randomizeMaps(amount);
	}

	while (maps.size != amount)
	{
		picked = rotation[randomInt(rotation.size)];
		rotation = Remove(rotation, picked);

		// Found map
		if (!Contains(playedMaps, picked))
		{
			maps[maps.size] = picked;
			FILE_WriteLine(file, picked);
		}
	}
	FILE_Close(file);
	level.randomizedMaps = maps;
}

getRotation(includeCurrent)
{
	list = [];
	currentMap = level.map;
	maps = StrTok(getDvar("sv_maprotation"), " ");
	maps = Remove(maps, "gametype");
	maps = Remove(maps, "map");

	for (i = 0; i < maps.size; i++)
	{
		if (currentMap == maps[i] && !includeCurrent)
			continue;
		list[list.size] = maps[i];
	}
	return list;
}

spawnSpectator()
{
	self endon("disconnect");

	self cleanUp();
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.statusicon = "";
	spawn = IfUndef(self.spawnPoint, level.spawn["spectator"]);
	self spawn(spawn.origin, spawn.angles);
	self sr\game\_teams::setSpectatePermissions();
	self.spawnPoint = undefined;
}
