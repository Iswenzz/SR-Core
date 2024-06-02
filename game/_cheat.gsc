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
	if (isDefined(self.cheating))
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

	self setRollback();

	while (true)
	{
		if (self antiLag() || self antiElevator())
			self rollback();
		else if (self isOnGround())
			self setRollback();
		wait 0.05;
	}
}

antiLag()
{
	if (self isAxis() || !self.antiLag)
		return false;

	return self getFPS() <= 10 || self getPing() >= 800;
}

antiElevator()
{
	if (self isAxis() || !self.antiElevator)
		return false;

	position = self.origin + (0, 0, 35);
    surface = self findClosestSurface(position);

    if (!isDefined(surface))
        return false;

	return distance(surface, position) == 14.875;
}

rollback()
{
	self setOrigin(self.previousOrigin);
	self setVelocity(self.previousVelocity);
	self setStance(self.previousStance);
}

setRollback()
{
	self.previousOrigin = self getOrigin();
	self.previousVelocity = self getVelocity();
	self.previousStance = self getStance();
}
