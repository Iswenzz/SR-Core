#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_math;

main()
{
	event("spawn", ::spray);
}

spray()
{
	self endon("disconnect");
	self endon("spawned_player");
	self endon("joined_spectators");
	self endon("death");

	if (!level.dvar["sprays"])
		return;

	while (game["state"] != "playing")
		wait 0.05;

	while (self isReallyAlive())
	{
		while (!self fragButtonPressed())
			wait .2;

		angles = self getPlayerAngles();
		eye = self getTagOrigin("j_head");
		forward = eye + vectorScale(anglesToForward(angles), 70);
		trace = bulletTrace(eye, forward, false, self);

		if (trace["fraction"] == 1)
		{
			wait 0.1;
			continue;
		}

		position = trace["position"] - vectorScale(anglesToForward(angles), -2);
		angles = vectorToAngles(eye - position);
		forward = anglesToForward(angles);
		up = anglesToUp(angles);

		sprayNum = self getStat(979);
		playFx(level.assets["spray"][sprayNum]["effect"], position, forward, up);
		self playSound("sprayer");

		self notify("spray", sprayNum, position, forward, up);
		delay = Ternary(self sr\sys\_admins::isRole("owner"), 0.05, level.dvar["sprays_delay"]);
		wait delay;
	}
}
