#include sr\utils\_common;

createNormalWays(token)
{
	ways = [];
	names = strTok(token, ";");

	for (i = 0; i < names.size; i++)
	{
		way = fmt("normal_%d", i);
		name = names[i];
		speedrun\core\_leaderboards::addWay(way, name);
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
		speedrun\core\_leaderboards::addWay(way, name);
	}
}

createEndMap(origin, width, height, way)
{
	if (!isDefined(way))
		return sr\api\_map::createEndMap(origin, width, height);

	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.radius = width;
	trigger.targetname = "sr_end_" + way;

	thread watchTriggerEndMap(trigger, way);
	thread sr\fx\_trigger::effect(trigger, "red");
	return trigger;
}

createModeSpawn(mode, origin, angles)
{
	modes = getModes(mode);

	point = spawn("script_origin", (origin[0], origin[1], origin[2] - 60));
	point.angles = (0, angles, 0);

	for (i = 0; i < modes.size; i++)
		level.spawn["mode_" + modes[i]] = point;
	return point;
}

createModeEndMap(mode, origin, width, height, way)
{
	modes = getModes(mode);

	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.radius = width;
	trigger.height = height;
	trigger.targetname = "sr_end_mode";

	thread watchModeEndMap(trigger, modes, way);
	thread sr\fx\_trigger::effect(trigger, "red");
	return trigger;
}

getModeName(mode)
{
	names = strTok("190;210;COD4;Q3;Q3CPM;Q3CPMW;CS;Portal", ";");
	for (i = 0; i < names.size; i++)
	{
		if (toLower(names[i]) == toLower(mode))
			return names[i];
	}
	return undefined;
}

getModes(mode)
{
	modes = [];
	name = getModeName(mode);

	if (!isDefined(name))
		return modes;
	if (name == "COD4")
	{
		modes[0] = "190";
		modes[1] = "210";
		return modes;
	}
	modes[0] = name;
	return modes;
}

createEndMapFromEntity(value, key, index, way)
{
	trigger = getEntArray(value, key)[index];

	thread watchTriggerEndMap(trigger, IfUndef(way, "normal_0"));
	thread sr\fx\_trigger::effect(trigger, "red");
	return trigger;
}

createWay(triggerOrigin, width, height, color, way)
{
	trigger = spawn("trigger_radius", triggerOrigin, 0, width, height);
	trigger.radius = width;
	trigger.targetname = "sr_" + way;

	thread watchWay(trigger, way);
	thread sr\fx\_trigger::effect(trigger, IfUndef(color, "blue"));
	return trigger;
}

createWayFromEntity(value, key, index, color, way)
{
	trigger = getEntArray(value, key)[index];

	thread watchWay(trigger, way);
	thread sr\fx\_trigger::effect(trigger, IfUndef(color, "blue"));
	return trigger;
}

createTeleporter(triggerOrigin, width, height, origin, angles, state, color, way)
{
	if (!isDefined(way))
		return sr\api\_map::createTeleporter(triggerOrigin, width, height, origin, angles, state, color);

	trigger = spawn("trigger_radius", triggerOrigin, 0, width, height);
	trigger.radius = width;
	trigger.targetname = "sr_teleport_" + way;

	thread watchTeleporter(trigger, origin, angles, state, way);
	thread sr\fx\_trigger::effect(trigger, IfUndef(color, "blue"));
	return trigger;
}

createTeleporterToEntity(triggerOrigin, width, height, value, key, index, state, color, way)
{
	if (!isDefined(way))
		return sr\api\_map::createTeleporterToEntity(triggerOrigin, width, height, value, key, index, state, color);

	trigger = spawn("trigger_radius", triggerOrigin, 0, width, height);
	trigger.radius = width;
	trigger.targetname = "sr_teleport_" + way;

	to = getEntArray(value, key)[index];

	thread watchTeleporter(trigger, to.origin, to.angles, state, way);
	thread sr\fx\_trigger::effect(trigger, IfUndef(color, "blue"));
	return trigger;
}

watchTriggerEndMap(trig, way)
{
	while (true)
	{
		trig waittill("trigger", player);
		player finishWay(way);
	}
}

watchModeEndMap(trigger, modes, way)
{
	while (true)
	{
		trigger waittill("trigger", player);

		if (isDefined(way) && player.sr_way != way)
			continue;
		for (i = 0; i < modes.size; i++)
		{
			if (player.sr_mode == modes[i])
				player thread speedrun\core\_run::endTimer();
		}
	}
}

watchWay(trigger, way)
{
	while (true)
	{
		trigger waittill("trigger", player);

		if (isDefined(way))
			player changeWay(way);
	}
}

watchTeleporter(trigger, origin, angles, state, way)
{
	while (true)
	{
		trigger waittill("trigger", player);

		if (isDefined(way))
			player changeWay(way);

		player thread sr\api\_map::playerTeleport(origin, angles, state);
	}
}

changeWay(way)
{
	self thread sr\libs\portal\_portal_gun::resetPortals();

	self.sr_way = way;
	self playLocalSound("change_way");
	self thread speedrun\huds\_speedrun::updateWay();
}

finishWay(way)
{
	if (self.sr_way == way)
		self thread speedrun\core\_run::endTimer();
}
