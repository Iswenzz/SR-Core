#include sr\player\fx\_shaders;

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
	level.huds["debug"].x = -5;
	level.huds["debug"].y = -5;
	level.huds["debug"].sort = 1000;
	level.huds["debug"].fontScale = 1.4;
	level.huds["debug"].color = (1, 1, 1);
	level.huds["debug"].hidewheninmenu = true;
	level.huds["debug"].alpha = 1;
	level.huds["debug"].archived = false;
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
		level thread [[sequence.callback]]();

		wait sequence.time;

		stop();
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
