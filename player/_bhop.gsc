#include sr\utils\_common;
#include sr\utils\_math;

loop()
{
	self endon("spawned");
	self endon("disconnect");
	self endon("death");

	self.bhopPrevAirVelocity = (0, 0, 0);
	self.bhopPrevOnGround = true;

	wait 0.05;

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
