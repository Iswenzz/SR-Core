#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	if (!getDvarInt("debug"))
		return;

	event("map", ::debugTriggers);
}

debugTriggers()
{
	triggers = [];
	triggers[triggers.size] = getEntArray("trigger_damage","classname");
	triggers[triggers.size] = getEntArray("trigger_disk","classname");
	triggers[triggers.size] = getEntArray("trigger_friendlychain","classname");
	triggers[triggers.size] = getEntArray("trigger_hurt","classname");
	triggers[triggers.size] = getEntArray("trigger_lookat","classname");
	triggers[triggers.size] = getEntArray("trigger_multiple","classname");
	triggers[triggers.size] = getEntArray("trigger_once","classname");
	triggers[triggers.size] = getEntArray("trigger_radius","classname");
	triggers[triggers.size] = getEntArray("trigger_use","classname");
	triggers[triggers.size] = getEntArray("trigger_use_touch","classname");

	for (i = 0; i < triggers.size; i++)
	{
		for (t = 0; t < triggers[i].size; t++)
			triggers[i][t] thread triggerPlayerLoop();
	}
}

triggerPlayerLoop()
{
	while (isDefined(self))
	{
		self waittill("trigger");

		if (isDefined(self.targetname))
			iPrintLnBold("^5Targetname: ^7" + self.targetname);
		if (isDefined(self.target))
			iPrintLnBold("^1Target: ^7" + self.target);

		wait 0.5;
	}
}
