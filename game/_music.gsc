#include sr\utils\_common;
#include sr\player\fx\_shaders;

main()
{
	level.music_sequence = [];

	add("end_map2", ::promoThunderstorm, 50);
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
		wait 0.2;

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
	thread promoBlurRotate(4, true);

	time = timeline(time, 20.1);
	thread promoTranslateY();

	time = timeline(time, 21.4);
	thread promoKick2(15);
	thread promoBlurRadial(4, true);

	time = timeline(time, 30.3);
	thread promoTranslateY();
	thread promoBlurRadial(7, false);
}

promoTranslateY()
{
	level translate(0, 1, 0.8);
	wait 0.4;
	level clearShader("translate");
}

promoBlurRotate(amount, blackScreen)
{
	wait 2.5;

	for (i = 0; i < amount; i++)
	{
		if (blackScreen)
		{
			level edge((0.1, 0.1, 0.1), 1);
			wait 0.1;
			level clearShader("edge");
		}
		level blur(0.8, 1, 1);
		wait 2.4;
		level clearShader("blur");
	}
}

promoBlurRadial(amount, blackScreen)
{
	wait 2.5;

	for (i = 0; i < amount; i++)
	{
		if (blackScreen)
		{
			level edge((0.1, 0.1, 0.1), 1);
			wait 0.1;
			level clearShader("edge");
		}
		level blur(0.4, 1, 1);
		wait 2.4;
		if (!blackScreen)
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

		level shake(0.3, 0.3, 0.2, 0);
		wait 0.55;
	}
}

timeline(total, time)
{
	wait time - total;
	return time;
}
