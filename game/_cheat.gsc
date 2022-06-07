#include sr\sys\_events;

main()
{
	event("connect", ::loop);
}

loop()
{
	self endon("disconnect");
	self.sr_cheat = false;

	while (true)
	{
		self.previousOrigin = self.origin;
		waittillframeend;

		if (!self isPlaying())
			continue;

		self antiLowFps();
		self antiElevator();
	}
}

antiLowFps()
{
	if (self.sr_cheat || self.pers["team"] == "axis" || !self.antiLowFps)
		return;

	if (self.fps < 1)
		self suicide();
}

antiElevator()
{
	if (self.sr_cheat || self.pers["team"] == "axis" || !self.antiElevator)
		return;

	inAir = !self isOnGround() && !self isOnLadder() && !self isMantling();
	if (inAir && self.origin[2] != self.previousOrigin[2] && self.velocity == (0, 0, 0))
		self suicide();
}
