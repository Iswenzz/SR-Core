#include sr\utils\_common;
#include sr\utils\_math;
#include sr\sys\_events;

main()
{
	event("spawn", ::onSpawn);
}

onSpawn()
{
	self endon("spawned");
	self endon("disconnect");
	self endon("death");

	if (!self isDefrag())
		return;

	self.bhopPrevAirVelocity = (0, 0, 0);
	self.bhopPrevOnGround = true;

	while (true)
	{
		self.bhopAirVelocity = self getVelocity();
		self.bhopOnGround = self isOnGround();
		self.bhopHeight = sqrt((self.jumpHeight * 2) * self.gravity);

		if (self.bhopOnGround && !self.bhopPrevOnGround && self jumpButtonPressed() && self getStance() == "stand")
		{
			velocity = self.bhopPrevAirVelocity - self.bhopAirVelocity;

			flags = self PmFlags();
			flags &= 4294966911;
  			flags |= 16384;
			self SetPmFlags(flags);
			self SetPmTime(0);

			self setVelocity((self.bhopAirVelocity[0], self.bhopAirVelocity[1], 0)
				+ (velocity[0], velocity[1], self.bhopHeight));
		}
		wait 0.05;

		self.bhopPrevAirVelocity = self.bhopAirVelocity;
		self.bhopPrevOnGround = self.bhopOnGround;
	}
}
