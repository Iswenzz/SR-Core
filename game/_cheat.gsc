#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("connect", ::loop);
	event("spawn", ::antiCheat);
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
		self.previousVelocity = self getVelocity();
		wait 0.05;

		self antiLowFps();
		self antiElevator();
	}
}

antiCheat()
{
	self endon("disconnect");
	self endon("death");

	self.run = randomInt(999999999);

	cheat = false;
	if (self sr\game\minigames\_main::isInAnyQueue())
		cheat = true;
	if (self sr\player\modes\_main::isInAnyMode())
		cheat = true;
	self.sr_cheat = cheat;
}

antiLowFps()
{
	if (self.sr_cheat || self.pers["team"] == "axis" || !self.antiLowFps)
		return;

	if (self getCountedFPS() < 1)
		self suicide();
}

antiElevator()
{
	if (self.sr_cheat || self.pers["team"] == "axis" || !self.antiElevator)
		return;

	inAir = !self isOnGround() && !self isOnLadder() && !self isMantling();
	isMovingZ = self.origin[2] != self.previousOrigin[2];
	isSameVelocityZ = self getVelocity()[2] == self.previousVelocity[2];
	isVelocityNull = self getVelocity() == (0, 0, 0);

	if (inAir && isMovingZ && isVelocityNull)
		self suicide();
}
