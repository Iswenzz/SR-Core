#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("connect", ::loop);
}

loop()
{
	self endon("disconnect");
	self.sr_cheat = false;
	self.antiLowFps = true;
	self.antiElevator = true;

	while (true)
	{
		if (!self isPlaying())
		{
			wait 0.1;
			continue;
		}

		self.previousOrigin = self.origin;
		wait 0.05;

		self antiLowFps();
		self antiElevator();
	}
}

antiLowFps()
{
	if (self.sr_cheat || self.pers["team"] == "axis" || !self.antiLowFps)
		return;

	if (self getFPS() < 1)
		self suicide();
}

antiElevator()
{
	if (self.sr_cheat || self.pers["team"] == "axis" || !self.antiElevator)
		return;

	inAir = !self isOnGround() && !self isOnLadder() && !self isMantling();
	if (inAir && self.origin[2] != self.previousOrigin[2] && self getVelocity() == (0, 0, 0))
		self suicide();
}
