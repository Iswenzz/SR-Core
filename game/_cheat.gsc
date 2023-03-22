#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("connect", ::onConnect);
	event("spawn", ::onSpawn);
}

onConnect()
{
	self.antiLag = true;
	self.antiElevator = true;
}

init()
{
	self.run = fmt("%d%d", randomInt(99999), randomInt(99999));

	cheat = false;
	if (self sr\game\minigames\_main::isInAnyQueue())
		cheat = true;
	if (self sr\player\modes\_main::isInAnyMode())
		cheat = true;
	if (self isDemo())
		cheat = true;
	if (self isBot())
		cheat = true;
	self cheat(cheat);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	wait 1;

	if (self isCheat())
		return;

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
	if (self isAxis() || !self.antiLag)
		return;

	if (self getFPS() <= 10 || self getPing() >= 800)
		self suicide();
}

antiElevator()
{
	if (self isAxis() || !self.antiElevator)
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
