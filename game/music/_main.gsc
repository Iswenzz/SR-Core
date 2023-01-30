#include sr\player\fx\_shaders;
#include sr\sys\_file;
#include sr\utils\_common;

initMusics()
{
	level.music_sequence = [];
	level.music_sequence_ents = [];

	precache();

	add("end_map1", "moment", 56, sr\game\music\_moment::sequence);
	add("end_map2", "thunderstorm", 46, sr\game\music\_thunderstorm::sequence);
	add("end_map3", "face_the_truth", 39, sr\game\music\_face_the_truth::sequence);
	add("end_map4", "first_contact", 48, sr\game\music\_first_contact::sequence);
	add("end_map5", "japanese_nightclub", 51, sr\game\music\_japanese_nightclub::sequence);
	add("end_map6", "triptonite", 53, sr\game\music\_triptonite::sequence);
	add("end_map7", "together", 45, sr\game\music\_together::sequence);
	add("end_map8", "symphony", 60, sr\game\music\_symphony::sequence);
	add("end_map9", "fuji", 59, sr\game\music\_fuji::sequence);

	if (getDvarInt("vegas"))
		vegas();
}

precache()
{
	level.gfx["blue_particles"] = loadFX("deathrun/blue_particles");
	level.gfx["thunder"] = loadFX("weather/lightning_mp_farm");
	level.gfx["rain"] = loadFX("weather/rain_mp_farm");
	level.gfx["snow"] = loadFX("weather/snow_light_mp_bloc");
}

add(alias, name, time, sequence)
{
	level.music_sequence[alias] = spawnStruct();
	level.music_sequence[alias].alias = alias;
	level.music_sequence[alias].name = name;
	level.music_sequence[alias].callback = sequence;
	level.music_sequence[alias].time = time;
	level.music_sequence[alias].keyframes = undefined;
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

load(name)
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

play(alias)
{
	level clear();
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
		sequence.keyframes = load(sequence.name);

	ambientPlay(sequence.alias, 0.2);
	wait 0.2;

	thread disableFullbright();
	thread disablePlayersAnimation();
	visionSetNaked("null", 0);
	level vision("default");
	level thread [[sequence.callback]](sequence);
	level thread animateKeyframes(sequence.keyframes);

	wait sequence.time;

	ambientStop(2);
	wait 2;

	level thread clear();
}

animateKeyframes(keyframes)
{
	level endon("music_sequence_end");

	startTime = getTime();
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

		self.huds["shader"] setShader(keyframe.name, 640, 480);
		self.huds["shader"].color = keyframe.color;
		self.huds["shader"].alpha = keyframe.alpha;
		self updateStack(keyframe.id, keyframe.name);
		i++;

		wait 0.05;
	}
}

clear()
{
	level notify("music_sequence_end");

	ambientStop(2);

	level removeShaders();
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] removeShaders();

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

disablePlayersAnimation()
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] disableAnimation();
}

disableFullbright()
{
	level endon("music_sequence_end");

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
		players[i] setClientDvar("r_fullbright", 0);
}

disableAnimation()
{
	if (self.settings["gfx_music_animation"])
		return;

	self.huds["vision"] = newClientHudElem(self);
	self.huds["vision"].foreground = true;
	self.huds["vision"].alignX = "left";
	self.huds["vision"].alignY = "top";
	self.huds["vision"].horzAlign = "fullscreen";
	self.huds["vision"].vertAlign = "fullscreen";
	self.huds["vision"].x = 0;
	self.huds["vision"].y = 0;
	self.huds["vision"].sort = -1;
	self.huds["vision"].fontScale = 1.4;
	self.huds["vision"].color = (0, 0, 0);
	self.huds["vision"].hidewheninmenu = true;
	self.huds["vision"].alpha = 1;
	self.huds["vision"].archived = false;
	self.huds["vision"] setShader("sr_translate", 640, 480);
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
	level.huds["vegas"].sort = -1;
	level.huds["vegas"].fontScale = 1.4;
	level.huds["vegas"].color = (0, 0, 0);
	level.huds["vegas"].hidewheninmenu = true;
	level.huds["vegas"].alpha = 1;
	level.huds["vegas"].archived = false;
	level.huds["vegas"] setShader("sr_translate", 640, 480);

	visionSetNaked("null", 0);
}
