#include sr\player\fx\_shaders;
#include sr\sys\_file;

initMusics()
{
	level.music_sequence = [];
	precache();

	add("end_map2", "thunderstorm", 50, sr\game\music\_thunderstorm::sequence);

	if (true) // @todo dvar
		debug();
}

debug()
{
	level.huds["debug"] = newHudElem();
	level.huds["debug"].foreground = true;
	level.huds["debug"].alignX = "left";
	level.huds["debug"].alignY = "top";
	level.huds["debug"].horzAlign = "fullscreen";
	level.huds["debug"].vertAlign = "fullscreen";
	level.huds["debug"].x = 0;
	level.huds["debug"].y = 0;
	level.huds["debug"].sort = 1001;
	level.huds["debug"].fontScale = 1.4;
	level.huds["debug"].color = (1, 1, 1);
	level.huds["debug"].hidewheninmenu = true;
	level.huds["debug"].alpha = 1;
	level.huds["debug"].archived = false;
	level.huds["debug"] setShader("sr_translate", 640, 480);
}

precache()
{
	level.fx["rain_heavy_mist"] = loadFX("weather/rain_mp_farm");
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

load(name)
{
	keyframes = [];
	file = FILE_Open(fmt(PATH_Mod("sr/data/keyframes/%s.keyframes"), name), "r+");

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
	if (isDefined(sequence))
	{
		ambientPlay(sequence.alias, 0.2);

		level vision("default");
		level thread [[sequence.callback]](sequence);

		if (isDefined(sequence.keyframes))
			level thread animateKeyframes(sequence.keyframes);

		wait sequence.time;

		stop();
	}
}

animateKeyframes(keyframes)
{
	level endon("music_sequence_end");
	time = 0;

	wait 0.2;

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

stop()
{
	ambientStop(0.2);
	wait 0.2;

	level notify("music_sequence_end");
	wait 0.1;
	level removeShaders();
}

timeline(total, time)
{
	wait time - total;
	return time;
}
