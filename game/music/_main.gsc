#include sr\player\fx\_shaders;
#include sr\sys\_file;

initMusics()
{
	level.music_sequence = [];
	level.music_sequence_ents = [];
	precache();

	add("end_map2", "thunderstorm", 46, sr\game\music\_thunderstorm::sequence);
	add("end_map3", "face_the_truth", 40, sr\game\music\_face_the_truth::sequence);

	if (getDvarInt("vegas"))
		vegas();

	thread test();
}

test()
{

}

precache()
{
	level.fx["thunder"] = loadFX("weather/lightning_mp_farm");
	level.fx["rain"] = loadFX("weather/rain_mp_farm");
}

add(alias, name, time, sequence)
{
	level.music_sequence[alias] = spawnStruct();
	level.music_sequence[alias].alias = alias;
	level.music_sequence[alias].name = name;
	level.music_sequence[alias].callback = sequence;
	level.music_sequence[alias].time = time;
	level.music_sequence[alias].keyframes = load(name);
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

		time = ToInt(tkn[0]) / 1000;
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

	ambientPlay(sequence.alias, 0.2);
	wait 0.2;

	visionSetNaked("null", 0);
	level vision("default");
	level thread [[sequence.callback]](sequence);

	if (isDefined(sequence.keyframes))
		level thread animateKeyframes(sequence.keyframes);

	wait sequence.time;

	ambientStop(2);
	wait 2;

	level thread clear();
}

animateKeyframes(keyframes)
{
	level endon("music_sequence_end");
	time = 0;

	for (i = 0; i < keyframes.size; i++)
	{
		keyframe = keyframes[i];

		time = timeline(time, keyframe.time);

		self.huds["shader"] setShader(keyframe.name, 640, 480);
		self.huds["shader"].color = keyframe.color;
		self.huds["shader"].alpha = keyframe.alpha;
		self updateStack(keyframe.id, keyframe.name);
	}
}

clear()
{
	level notify("music_sequence_end");

	ambientStop(2);
	level removeShaders();
	setExpFog(20000000, 10000000, 0, 0, 0, 2);

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
	level.huds["vegas"].sort = 1;
	level.huds["vegas"].fontScale = 1.4;
	level.huds["vegas"].color = (1, 1, 1);
	level.huds["vegas"].hidewheninmenu = true;
	level.huds["vegas"].alpha = 1;
	level.huds["vegas"].archived = false;
	level.huds["vegas"] setShader("sr_translate", 640, 480);
}
