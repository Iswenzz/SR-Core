#include speedrun\game\_leaderboards;

createNormalWays(token)
{
	ways = [];
	names = strTok(token, ";");

	for (i = 0; i < names.size; i++)
	{
		way = fmt("normal_%d", i);
		name = names[i];
		addWay(way, name);
	}
}

createSecretWays(token)
{
	ways = [];
	names = strTok(token, ";");

	for (i = 0; i < names.size; i++)
	{
		way = fmt("secret_%d", i);
		name = names[i];
		addWay(way, name);
	}
}

changeWay(way)
{
	self thread sr\libs\portal\_portal_gun::resetPortals();

	self.sr_way = way;
	self playLocalSound("change_way");
	self thread speedrun\player\huds\_speedrun::updateWay();
}

finishWay(way)
{
	if (self.sr_way == way)
		self thread speedrun\player\run\_main::endTimer();
}

createEndMap(origin, width, height, way)
{
	// Default way
	if (!isDefined(way))
	{
		sr\api\_map::createEndMap(origin, width, height);
		return;
	}
	trig = spawn("trigger_radius", origin, 0, width, height);
	trig.radius = width;

	thread watchTriggerEndMap(trig, way);
	thread sr\game\fx\_trigger::effect(trig, "red");
}

watchTriggerEndMap(trig, way)
{
	while (true)
	{
		trig waittill("trigger", player);
		player finishWay(way);
	}
}

createTeleporter(triggerOrigin, width, height, origin, angles, state, color, way)
{
	trigger = spawn("trigger_radius", triggerOrigin, 0, width, height);
	trigger.radius = width;

	thread watchTeleporter(trigger, origin, angles, state, way);
	thread sr\game\fx\_trigger::effect(trigger, IfUndef(color, "blue"));
}

watchTeleporter(trigger, origin, angles, state, way)
{
	while (true)
	{
		trigger waittill("trigger", player);

		if (isDefined(way))
			player changeWay(way);

		player thread playerTeleport(origin, angles, state);
	}
}

playerTeleport(origin, angles, state)
{
	self endon("death");
	self endon("disconnect");

	if (state == "freeze")
	{
		self sr\api\_player::antiElevator(false);
		self freezeControls(true);
	}

	self setOrigin(origin);
	self setPlayerAngles((0, angles, 0));

	if (state == "freeze")
	{
		wait 0.05;
		self freezeControls(false);
		self sr\api\_player::antiElevator(true);
	}
}

cj()
{
	level.map_cj = true;
}

slide(speed)
{
	level.map_slide = true;
	level.map_slide_multiplier = speed;
}

isCJ()
{
	return isDefined(level.map_cj) && level.map_cj;
}

isSlide()
{
	return isDefined(level.map_slide) && level.map_slide;
}
