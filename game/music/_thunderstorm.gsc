#include sr\game\music\_main;
#include sr\player\fx\_shaders;

sequence()
{
	level endon("music_sequence_end");

	time = timeline(0, 11.2);
	thread kick(13);
	thread blurRotate(4, true);

	time = timeline(time, 20.1);
	thread translateY();

	time = timeline(time, 21.4);
	thread kick2(15);
	thread blurRadial(4, true);

	time = timeline(time, 30.3);
	thread translateY();
	thread blurRadial(7, false);
}

translateY()
{
	level endon("music_sequence_end");

	level translate("translateY", 0, 1, 0.8);
	wait 0.4;
	level clearShader("translateY");
}

blurRotate(amount, blackScreen)
{
	level endon("music_sequence_end");
	wait 2.5;

	for (i = 0; i < amount; i++)
	{
		if (blackScreen)
		{
			level edge("blackscreen", (0.1, 0.1, 0.1), 1);
			wait 0.1;
			level clearShader("blackscreen");
		}
		level blur("blurRotate", 0.8, 1, 1);
		wait 2.4;
		level clearShader("blurRotate");
	}
}

blurRadial(amount, blackScreen)
{
	level endon("music_sequence_end");
	wait 2.5;

	for (i = 0; i < amount; i++)
	{
		if (blackScreen)
		{
			level edge("blackscreen", (0.1, 0.1, 0.1), 1);
			wait 0.1;
			level clearShader("blackscreen");
		}
		level blur("blurRadial", 0.4, 1, 1);
		wait 2.4;
		if (!blackScreen)
			level clearShader("blurRadial");
	}
}

kick(amount)
{
	level endon("music_sequence_end");

	for (i = 0; i < amount; i++)
	{
		level edge("blackscreen", (0.1, 0.1, 0.1), 1);
		wait 0.1;
		level clearShader("blackscreen");

		level zoom("kick", 1, 0.8, 0.1);
		wait 0.55;
	}
	level clearShader("kick");
}

kick2(amount)
{
	level endon("music_sequence_end");

	for (i = 0; i < amount; i++)
	{
		level edge("blackscreen", (0.1, 0.1, 0.1), 1);
		wait 0.1;
		level clearShader("blackscreen");

		level shake("kick2", 0.3, 0.3, 0.2, 0);
		wait 0.55;
	}
	level clearShader("kick2");
}
