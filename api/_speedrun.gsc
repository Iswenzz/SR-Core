#include speedrun\game\_leaderboards;

createNormalWays(token)
{
	way = strTok(token, ";");

	for (i = 0; i < way.size; i++)
		createWay(way[i], i, "normal");
}

createSecretWays(token)
{
	way = strTok(token, ";");

	for (i = 0; i < way.size; i++)
		createWay(way[i], i, "secret");
}

createWay(name, index, section)
{
	id = fmt("%s_%d", section, index);
	addWay(id, name);
}

changeWay(way)
{
	self.sr_way = way;
	self playLocalSound("change_way");
}

finishWay(way)
{
	if (self.sr_way == way)
		self thread braxi\_mod::endTimer();
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
	thread sr\game\fx\_trigger::createTrigFx(trig, "red");
}

watchTriggerEndMap(trig, way)
{
	while (true)
	{
		trig waittill("trigger", player);
		player finish_way(way);
	}
}

createTeleporter(triggerOrigin, width, height, origin, angles, state, color, way)
{
	trigger = spawn("trigger_radius", triggerOrigin, 0, width, height);
	trigger.radius = width;

	thread watchTeleporter(trigger, origin, angles, state, way);
	thread sr\game\fx\_trigger::createTrigFx(trigger, IfUndef(color, "blue"));
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
		self freezeControls(true);

	self setOrigin(origin);
	self setPlayerAngles((0, angles, 0));

	if (state == "freeze")
	{
		wait 0.05;
		self freezeControls(false);
	}
}
