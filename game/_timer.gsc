hud(time, callbackEnd)
{
    level endon("time_update");
	level.sr_time = time;

	clock = spawn("script_origin", (0, 0, 0));

	while (level.sr_time > 0)
	{
		wait 1;
		level.sr_time--;
        
		if (level.sr_time == 180)
			iprintlnbold("^1Map will end in 3 minutes!");
		else if (level.sr_time <= 60 && level.sr_time > 10 && level.sr_time % 2 == 0)
		{
			clock playSound("ui_mp_timer_countdown");
			level.hud_time.color = (1, 140 / 255, 0);
		}
		else if (level.sr_time <= 10)
		{
			clock playSound("ui_mp_timer_countdown");
			level.hud_time.color = (1, 0, 0);
		}
		else if (level.sr_time >= 60)
			level.hud_time.color = (1, 1, 1);
	}
	clock delete();
	level thread [[callbackEnd]]();
}
