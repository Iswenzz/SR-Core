#include sr\utils\_common;
#include sr\player\fx\_shaders;

main()
{
	level.music_sequence = [];

	add("end_map2", ::promoThunderstorm, 51);
}

add(alias, sequence, time)
{
	level.music_sequence[alias] = spawnStruct();
	level.music_sequence[alias].callback = sequence;
	level.music_sequence[alias].time = time;
}

play(alias)
{
	sequence = level.music_sequence[alias];
	if (isDefined(sequence))
	{
		level thread [[sequence.callback]](alias);

		wait sequence.time;

		ambientStop(0.2);
		level notify("music_sequence_end");
		level clearShaders();
	}
}

promoThunderstorm(alias)
{
	time = 0;
	ambientPlay(alias, 0.2);

	time = timeline(time, 11.2);
	thread promoKick(13);
	thread promoBlurRotate(4);

	time = timeline(time, 19.9);
	thread promoTranslateY();

	time = timeline(time, 21.4);
	thread promoKick2(16);
	thread promoBlurRadial(16);

	time = timeline(time, 30.3);
	thread promoTranslateY();
}

promoTranslateY()
{
	level translate(0, 1, 0.8);
	wait 0.4;
	level clearShader("translate");
}

promoBlurRotate(amount)
{
	wait 2.5;

	for (i = 0; i < amount; i++)
	{
		level edge((0.1, 0.1, 0.1), 1);
		wait 0.1;
		level clearShader("edge");

		level blur(0.8, 1, 1);
		wait 2.4;
		level clearShader("blur");
	}
}

promoBlurRadial(amount)
{
	wait 2.5;

	for (i = 0; i < amount; i++)
	{
		level edge((0.1, 0.1, 0.1), 1);
		wait 0.1;
		level clearShader("edge");

		level blur(0.4, 1, 1);
		wait 2.4;
		level clearShader("blur");
	}
}

promoKick(amount)
{
	for (i = 0; i < amount; i++)
	{
		level edge((0.1, 0.1, 0.1), 1);
		wait 0.1;
		level clearShader("edge");

		level zoom(1, 0.8, 0.1);
		wait 0.55;
	}
}

promoKick2(amount)
{
	for (i = 0; i < amount; i++)
	{
		level edge((0.1, 0.1, 0.1), 1);
		wait 0.1;
		level clearShader("edge");

		level zoom(1, 1, 0.1);
		wait 0.55;
	}
}

timeline(total, time)
{
	wait time - total;
	return time;
}
