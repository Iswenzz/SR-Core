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

	thread randomizeMaps(5);

	event("map", ::placeSpawns);
	event("map", ::deleteUnsupportedWeapons);
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
	if (!isDefined(level.spawn["player"]))
	{
		level.spawn["player"] = spawn("script_origin", (x, y, z));
		level.spawn["player"].angles = angles;
		level.spawn["player"] placeSpawnPoint();
	}
}

end(map)
{
	if (game["state"] == "end")
		return;

	game["state"] = "end";
	level notify("intermission");
	level notify("game over");

	// Sequence
	endMusic();
	endSpectate();
	displayMapScores();

	if (IsNullOrEmpty(map))
		map = voteNextMap();

	credits();
	intermission();

	// Next map
	setDvar("sv_maprotationcurrent", fmt("gametype %s map %s", getDvar("g_gametype"), map));
	levelExit(false);
}

endMusic()
{
	alias = fmt("end_map%d", randomIntRange(1, 9));
	thread sr\game\music\_main::play(alias);
}

endSpectate()
{
	setDvar("g_deadChat", 1);

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
		players[i] sr\game\_teams::setTeam("spectator");
		players[i] eventSpectator();
		players[i] allowSpectateTeam("freelook", false);
		players[i] allowSpectateTeam("none", true);
	}
}

levelRestart(persist)
{
	game["ended"] = true;
	waitCriticalSections();

	map_restart(persist);
}

levelExit(persist)
{
	game["ended"] = true;
	waitCriticalSections();

	exitLevel(persist);
}

displayMapScores()
{
	wait 1;

	if (!level.dvar["map_scores"])
		return;
}

voteNextMap()
{
	maps = level.randomizedMaps;

	if (level.dvar["map_vote"])
		return vote(maps);
	wait 18;
	return maps[randomInt(maps.size)];
}

credits()
{
	sr\game\_credits::start();
}

intermission()
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i].sessionstate = "intermission";
	wait 10;
}

vote(maps)
{
	result = sr\game\_poll::poll("Next map", maps);
	if (isDefined(result))
	{
		level sr\sys\_notifications::show(fmt("^5Next map: ^7%s", result.label));
		return result.label;
	}
	return maps[randomInt(maps.size)];
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
	return Sort(list);
}

addTime(minutes)
{
	level.time += minutes * 60;
	if (isDefined(level.huds["time"]))
		level.huds["time"] setTimer(level.time);
}

deleteUnsupportedWeapons()
{
	weapons = strTok("knife_mp,m16_gl_mp,ak74u_reflex_mp,ak74u_acog_mp,ak74u_silencer_mp,dog_mp,shovel_mp", ",");

	for (i = 0; i < weapons.size; i++)
	{
		ents = getEntArray("weapon_" + weapons[i], "classname");
		if (!isDefined(ents) || !ents.size)
			continue;

		for (j = 0; j < ents.size; j++)
			ents[j] delete();
	}
}
