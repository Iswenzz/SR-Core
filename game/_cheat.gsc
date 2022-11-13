#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("connect", ::loop);
	event("spawn", ::spawnLoop);
}

loop()
{
	self endon("disconnect");

	self.sr_cheat = false;
	self.antiLag = true;
	self.antiElevator = true;
}

spawnLoop()
{
	self endon("disconnect");
	self endon("death");

	self.run = fmt("%d%d", randomInt(99999), randomInt(99999));

	cheat = false;
	if (self sr\game\minigames\_main::isInAnyQueue())
		cheat = true;
	if (self sr\player\modes\_main::isInAnyMode())
		cheat = true;
	if (self isDemoPlaying())
		cheat = true;
	self.sr_cheat = cheat;

	if (self.isBot || self.sr_cheat) 
		return;

	wait 1;

	while (true)
	{
		self.previousOrigin = self.origin;
		self.previousVelocity = self getVelocity();
		wait 0.05;

		self antiLag();
		self antiElevator();
	}
}

antiLag()
{
	if (self.sr_cheat || self.pers["team"] == "axis" || !self.antiLag)
		return;

	if (self getFPS() <= 10 || self getPing() >= 800)
		self suicide();
}

antiElevator()
{
	if (self.sr_cheat || self.pers["team"] == "axis" || !self.antiElevator)
		return;

	inAir = !self isOnGround() && !self isOnLadder() && !self isMantling();
	isMovingZ = self.origin[2] != self.previousOrigin[2];
	isVelocityNullZ = self getVelocity()[2] == 0 && self.previousVelocity[2] == 0;

	if (inAir && isMovingZ && isVelocityNullZ)
	{
		self iPrintLn("^3ANTI-ELE");
		self suicide();
	}
}
