#include sr\sys\_events;
#include sr\utils\_hud;

main()
{
	level.eventTime = 10000;

	event("map", ::hud);
}

hud()
{
	if (!level.dvar["event"])
		return;

	eventTime = level.eventTime;
	time = eventTime;

	level.huds["event"]["text"] = addHud(level, 0, 70, 1, "center", "middle", 1.6, 1000, true);
	level.huds["event"]["text"] setText("^2Event starts in");
	level.huds["event"]["timer"] = addHud(level, 0, 90, 1, "center", "middle", 1.4, 1000, true);
	level.huds["event"]["timer"] setTimer(time);

	while (time)
	{
		if (level.eventTime != eventTime)
		{
			eventTime = level.eventTime;
			time = eventTime;
			level.huds["event"]["timer"] setTimer(time);
		}
		wait 1;
		time--;
	}
	level.huds["event"]["text"] destroy();
	level.huds["event"]["timer"] destroy();

	level.dvar["event"] = false;
}
