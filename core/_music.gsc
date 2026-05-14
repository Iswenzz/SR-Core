#include sr\sys\_file;
#include sr\utils\_common;

main()
{
	level.music_ambient = [];
	level.music_sequence = [];
	level.music_sequence_ents = [];

	precache();

	ambient("srm1", "cosita");
	ambient("srm2", "ways_to_die");
	ambient("srm3", "this_is_minecraft");
	ambient("srm4", "stal");
	ambient("srm5", "fn_despacito");
	ambient("srm6", "omg");
	ambient("srm7", "minecraft");
	ambient("srm8", "wario");
	ambient("srm9", "pipe");
	ambient("srm10", "dead");
	ambient("srm11", "delfino");
	ambient("srm12", "ninja");
	ambient("srm13", "xina");
	ambient("srm14", "wii");
	ambient("srm15", "ricardo");
	ambient("srm16", "fishe");
	ambient("srm17", "tense");
	ambient("srm18", "cow");
	ambient("srm19", "polish");
	ambient("srm20", "minion");
	ambient("srm21", "laogan");
	ambient("srm22", "fortnite");
	ambient("srm23", "wide");
	ambient("srm24", "dame");
	ambient("srm25", "wasted");
	ambient("srm26", "trap");
	ambient("srm27", "bing");
	ambient("srm28", "redsun");
	ambient("srm29", "heya");
	ambient("srm30", "fak");
	ambient("srm31", "gf");
	ambient("srm32", "auf");
	ambient("srm33", "boom");
	ambient("srm34", "nae");
	ambient("srm35", "diamond");
	ambient("srm36", "ocean");
	ambient("srm37", "ksi");
	ambient("srm38", "lighthouse");

	sequence("end_map1", "moment", 56, ::sequence_Moment);
	sequence("end_map2", "thunderstorm", 46, ::sequence_Thunderstorm);
	sequence("end_map3", "face_the_truth", 39, ::sequence_FaceTheTruth);
	sequence("end_map4", "first_contact", 48, ::sequence_FirstContact);
	sequence("end_map5", "japanese_nightclub", 51, ::sequence_JapaneseNightclub);
	sequence("end_map6", "triptonite", 53, ::sequence_Triptonite);
	sequence("end_map7", "together", 45, ::sequence_Together);
	sequence("end_map8", "symphony", 60, ::sequence_Symphony);
	sequence("end_map9", "fuji", 59, ::sequence_Fuji);

	if (getDvarInt("vegas"))
		vegas();
}

precache()
{
	level.gfx["blue_particles"] = loadFX("speedrun/blue_particles");
	level.gfx["thunder"] = loadFX("weather/lightning_mp_farm");
	level.gfx["rain"] = loadFX("weather/rain_mp_farm");
	level.gfx["snow"] = loadFX("weather/snow_light_mp_bloc");
}

sequence_FaceTheTruth(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_space_curvature");
	addEnt(skybox);

	while (true)
	{
		for (i = 0; i < 10; i++)
			addFX(level.gfx["blue_particles"], level.spawn["spectator"].origin);
		wait 10;
	}
}

sequence_FirstContact(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_space_curvature");
	addEnt(skybox);

	while (true)
	{
		for (i = 0; i < 10; i++)
			addFX(level.gfx["blue_particles"], level.spawn["spectator"].origin);
		wait 10;
	}
}

sequence_Fuji(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_aurora");
	addEnt(skybox);

	while (true)
	{
		for (i = 0; i < 10; i++)
			addFX(level.gfx["blue_particles"], level.spawn["spectator"].origin);
		wait 10;
	}
}

sequence_JapaneseNightclub(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_hexagon");
	addEnt(skybox);

	addFX(level.gfx["lasershow"], level.spawn["spectator"].origin);
}

sequence_Moment(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_space_curvature");
	addEnt(skybox);

	addFX(level.gfx["snow"], level.spawn["spectator"].origin);

	while (true)
	{
		for (i = 0; i < 10; i++)
			addFX(level.gfx["blue_particles"], level.spawn["spectator"].origin);
		wait 10;
	}
}

sequence_Symphony(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_space_curvature");
	addEnt(skybox);

	addFX(level.gfx["endgame"], level.spawn["spectator"].origin);

	while (true)
	{
		for (i = 0; i < 10; i++)
			addFX(level.gfx["blue_particles"], level.spawn["spectator"].origin);
		wait 10;
	}
}

sequence_Thunderstorm(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_space_curvature");
	addEnt(skybox);

	setExpFog(200, 500, 0, 0.04, 0.1, 0);

	addFX(level.gfx["rain"], level.spawn["spectator"].origin);
	for (i = 0; i < 30; i++)
		addFX(level.gfx["thunder"], level.spawn["spectator"].origin);

	while (true)
	{
		for (i = 0; i < 10; i++)
			addFX(level.gfx["blue_particles"], level.spawn["spectator"].origin);
		wait 10;
	}
}

sequence_Together(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_aurora");
	addEnt(skybox);

	while (true)
	{
		for (i = 0; i < 10; i++)
			addFX(level.gfx["blue_particles"], level.spawn["spectator"].origin);
		wait 10;
	}
}

sequence_Triptonite(animation)
{
	level endon("music_sequence_end");

	skybox = spawn("script_model", level.spawn["spectator"].origin);
	skybox setModel("x_hexagon");
	addEnt(skybox);
}

sequence(alias, name, time, sequence)
{
	level.music_sequence[alias] = spawnStruct();
	level.music_sequence[alias].alias = alias;
	level.music_sequence[alias].name = name;
	level.music_sequence[alias].callback = sequence;
	level.music_sequence[alias].time = time;
	level.music_sequence[alias].keyframes = undefined;
}

ambient(alias, name)
{
	level.music_ambient[name] = alias;
}

addEnt(ent)
{
	level.music_sequence_ents[level.music_sequence_ents.size] = ent;
	return ent;
}

addFX(effect, origin, forward, up)
{
	ent = undefined;
	if (isDefined(forward) && isDefined(up))
		ent = spawnFX(effect, origin, forward, up);
	else
		ent = spawnFX(effect, origin);

	triggerFX(ent);
	addEnt(ent);
}

loadSequence(name)
{
	path = fmt(PATH_Mod("sr/data/keyframes/%s.keyframes"), name);

	if (!FILE_Exists(path))
		return;

	keyframes = [];
	file = FILE_Open(path, "r+");

	while (true)
	{
		line = FILE_ReadLine(file);
		tkn = strTok(line, "/");

		if (IsNullOrEmpty(line) || tkn.size != 7)
			break;

		time = ToInt(tkn[0]);
		id = tkn[1];
		name = tkn[2];
		r = ToInt(tkn[3]) / 255;
		g = ToInt(tkn[4]) / 255;
		b = ToInt(tkn[5]) / 255;
		a = ToInt(tkn[6]) / 255;

		keyframe = spawnStruct();
		keyframe.time = time;
		keyframe.id = id;
		keyframe.name = name;
		keyframe.color = (r, g, b);
		keyframe.alpha = a;
		keyframes[keyframes.size] = keyframe;
	}

	FILE_Close(file);
	return keyframes;
}

playSequence(alias)
{
	clear();
	level endon("music_sequence_end");

	sequence = undefined;
	keys = getArrayKeys(level.music_sequence);

	for (i = 0; i < keys.size; i++)
	{
		if (isDefined(level.music_sequence[keys[i]]))
		{
			if (keys[i] == alias || level.music_sequence[keys[i]].name == alias)
			{
				sequence = level.music_sequence[keys[i]];
				break;
			}
		}
	}
	if (!isDefined(sequence))
		return;
	if (!isDefined(sequence.keyframes))
		sequence.keyframes = loadSequence(sequence.name);

	ambientPlay(sequence.alias, 0.2);
	wait 0.2;

	visionSetNaked("null", 0);
	level thread [[sequence.callback]](sequence);
	level thread animateKeyframes(sequence);

	wait sequence.time;

	ambientStop(2);
	wait 2;

	thread clear();
}

animateKeyframes(sequence)
{
	level endon("music_sequence_end");

	players = getAllPlayers();
	for (j = 0; j < players.size; j++)
	{
		player = players[j];
		if (!player.settings["gfx_music_animation"])
			continue;

		player setClientDvar("r_fullbright", 0);
		player sr\fx\_shaders::vision();
	}

	startTime = getTime();
	keyframes = sequence.keyframes;
	time = 0;
	i = 0;

	while (true)
	{
		if (!isDefined(keyframes[i]))
			break;

		keyframe = keyframes[i];
		time = getTime() - startTime;

		if (int(keyframe.time - time) > 50)
		{
			wait 0.05;
			continue;
		}

		players = getAllPlayers();
		for (j = 0; j < players.size; j++)
		{
			player = players[j];
			if (!player.settings["gfx_music_animation"])
				continue;

			player.huds["shader"] = player sr\fx\_shaders::addShader(keyframe.name);
			player.huds["shader"].color = keyframe.color;
			player.huds["shader"].alpha = keyframe.alpha;
		}
		i++;

		wait 0.05;
	}
}

clear()
{
	level notify("music_sequence_end");

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] sr\fx\_shaders::removeShaders();

	ambientStop(2);

	setExpFog(20000000, 10000000, 0, 0, 0, 2);
	visionSetNaked(toLower(level.map), 0);

	ents = level.music_sequence_ents;
	for (i = 0; i < ents.size; i++)
	{
		if (isDefined(ents[i]))
			ents[i] delete();
	}
	level.music_sequence_ents = [];
}

timeline(total, time)
{
	wait time - total;
	return time;
}

vegas()
{
	level.huds["vegas"] = newHudElem();
	level.huds["vegas"].foreground = true;
	level.huds["vegas"].alignX = "left";
	level.huds["vegas"].alignY = "top";
	level.huds["vegas"].horzAlign = "fullscreen";
	level.huds["vegas"].vertAlign = "fullscreen";
	level.huds["vegas"].x = 0;
	level.huds["vegas"].y = 0;
	level.huds["vegas"].sort = 0;
	level.huds["vegas"].fontScale = 1.4;
	level.huds["vegas"].color = (0, 0, 0);
	level.huds["vegas"].hidewheninmenu = true;
	level.huds["vegas"].alpha = 1;
	level.huds["vegas"].archived = true;
	level.huds["vegas"] setShader("sr_translate", 640, 480);

	visionSetNaked("null", 0);
}

playAmbient(name)
{
	stopAmbient();

	if (name == "stop")
		return;

	AmbientPlay(IfUndef(level.music_ambient[name], name), 0.05);
}

stopAmbient()
{
	AmbientStop(0.05);
}
