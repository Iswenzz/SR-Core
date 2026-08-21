#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("map", ::build);
	event("spawn", ::start);
}

build()
{
	level.sweptTriggers = [];

	addClass("trigger_multiple");
	addClass("trigger_once");
	addClass("trigger_use");
	addClass("trigger_use_touch");
	addClass("trigger_damage");
	addClass("trigger_hurt");
	addClass("trigger_lookat");
	addClass("trigger_radius");
}

addClass(classname)
{
	list = getEntArray(classname, "classname");
	for (i = 0; i < list.size; i++)
	{
		if (hasVolume(list[i]))
			level.sweptTriggers[level.sweptTriggers.size] = list[i];
	}
}

// A map trigger states its box; a radius one is spawned with a radius and a
// height, which the engine keeps as mins (-r, -r, 0) and maxs (r, r, height)
// and script cannot read back. Whoever spawns it records them instead.
hasVolume(trigger)
{
	if (isDefined(trigger.trig_min) && isDefined(trigger.trig_max))
		return true;
	return isDefined(trigger.radius) && isDefined(trigger.height);
}

start()
{
	self thread sweep();
}

sweep()
{
	self endon("death");
	self endon("disconnect");

	previous = self.origin;
	while (true)
	{
		wait 0.05;
		if (!isDefined(level.sweptTriggers))
		{
			previous = self.origin;
			continue;
		}

		current = self.origin;
		self step(previous, current);
		previous = current;
	}
}

step(from, to)
{
	// Fine enough that the thinnest trigger a map ships cannot fall between two
	// samples; a few hundred point tests a frame at worst.
	steps = int(distance(from, to) / 8);
	if (steps < 2)
		return;
	if (steps > 48)
		steps = 48;

	for (i = 0; i < level.sweptTriggers.size; i++)
	{
		trigger = level.sweptTriggers[i];
		// The list is built once, and a mode may have deleted one since.
		if (!isDefined(trigger))
			continue;
		// Inside at either end is what the engine already sees for itself.
		if (inside(trigger, from) || inside(trigger, to))
			continue;

		for (s = 1; s < steps; s++)
		{
			point = from + (to - from) * (s / (steps * 1.0));
			if (inside(trigger, point))
			{
				trigger notify("trigger", self);
				break;
			}
		}
	}
}

// The trigger box grown by the player's own, so a feet origin answers the same
// question the engine asks of the whole bounding box.
inside(trigger, point)
{
	if (isDefined(trigger.trig_min))
	{
		mins = trigger.trig_min - (15, 15, 70);
		maxs = trigger.trig_max + (15, 15, 0);
	}
	else
	{
		r = trigger.radius;
		mins = trigger.origin - (r + 15, r + 15, 70);
		maxs = trigger.origin + (r + 15, r + 15, trigger.height);
	}

	if (point[0] < mins[0] || point[0] > maxs[0])
		return false;
	if (point[1] < mins[1] || point[1] > maxs[1])
		return false;
	if (point[2] < mins[2] || point[2] > maxs[2])
		return false;
	return true;
}
