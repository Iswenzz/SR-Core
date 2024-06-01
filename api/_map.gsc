#include sr\utils\_common;

createEndMap(origin, width, height)
{
	array = getEntArray("endmap_trig", "targetname");
	for (i = 0; i < array.size; i++)
		array[i] delete();

	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "endmap_trig";
	trigger.radius = width;
	return trigger;
}

createTeleporter(triggerOrigin, width, height, origin, angles, state, color)
{
	trigger = spawn("trigger_radius", triggerOrigin, 0, width, height);
	trigger.radius = width;
	trigger.targetname = "sr_teleport";

	thread watchTeleporter(trigger, origin, angles, state);
	thread sr\game\fx\_trigger::effect(trigger, IfUndef(color, "blue"));
	return trigger;
}

createDeath(triggerOrigin, width, height)
{
	trigger = spawn("trigger_radius", triggerOrigin, 0, width, height);
	trigger.radius = width;
	trigger.targetname = "sr_death";

	thread watchDeath(trigger);
	return trigger;
}

watchTeleporter(trigger, origin, angles, state)
{
	while (true)
	{
		trigger waittill("trigger", player);
		player thread playerTeleport(origin, angles, state);
	}
}

watchDeath(trigger)
{
	while (true)
	{
		trigger waittill("trigger", player);
		player suicide();
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

createSpawn(origin, angles)
{
	level.spawn["player"] = spawn("script_origin", (origin[0], origin[1], origin[2] - 60));
	level.spawn["player"].angles = (0, angles, 0);
}

createSpawnOrigin(origin, angles)
{
	level.spawn["player"] = spawn("script_origin", origin);
	level.spawn["player"].angles = (0, angles, 0);
}

createTriggerFx(trigger, fx)
{
	thread sr\game\fx\_trigger::effect(trigger, fx);
}

noFallDamage()
{
	setDvar("bg_falldamagemaxheight", 2000000000);
	setDvar("bg_falldamageminheight", 1500000000);
}

getSpeed(speed)
{
	return int(ceil(getDvarInt("g_speed") * (speed / 190)));
}

getMoveSpeedScale(moveSpeedScale)
{
	return getDvarFloat("dr_jumpers_speed") * (moveSpeedScale / 1.05);
}

getGravity(gravity)
{
	return int(ceil(getDvarFloat("g_gravity") * (gravity / 800)));
}

getJumpHeight(jumpHeight)
{
	return int(ceil(getDvarFloat("jump_height") * (jumpHeight / 39)));
}
