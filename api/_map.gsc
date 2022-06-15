createEndMap(origin, width, height)
{
	if (isDefined(getEnt("endmap_trig", "targetname")))
	{
		temp = getEnt("endmap_trig", "targetname");
		temp delete();
	}

	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "endmap_trig";
	trigger.radius = width;
}

createTeleporter(triggerOrigin, width, height, origin, angles, state, color)
{
	trigger = spawn("trigger_radius", triggerOrigin, 0, width, height);
	trigger.radius = width;

	thread watchTeleporter(trigger, origin, angles, state);
	thread sr\game\fx\_trigger::effect(trigger, IfUndef(color, "blue"));
}

watchTeleporter(trigger, origin, angles, state)
{
	while (true)
	{
		trigger waittill("trigger", player);
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

createSpawn(origin, angles)
{
	level.masterSpawn = spawn("script_origin", (origin[0], origin[1], origin[2] - 60));
	level.masterSpawn.angles = (0, angles, 0);
}

createTriggerFx(trigger, fx)
{
	thread sr\game\fx\_trigger::effect(trigger, fx);
}

createSpawnAuto()
{
	spawns = getEntArray("mp_jumper_spawn", "classname");

	if (!spawns.size)
		return;

	origin = spawns[int(spawns.size / 2)].origin;
	angle = spawns[int(spawns.size / 2)].angles[1];

	level.masterSpawn = spawn("script_origin", origin);
	level.masterSpawn.angles = (0, angle, 0);
}
