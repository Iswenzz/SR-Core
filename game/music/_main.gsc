#include sr\player\fx\_shaders;

initMusics()
{
	level.music_sequence = [];

	add("end_map2", "thunderstorm", 50, sr\game\music\_thunderstorm::sequence);
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

		level vision();
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
