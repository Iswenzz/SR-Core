#include sr\utils\_common;
#include sr\utils\_math;

loop()
{
	self endon("disconnect");
	self endon("death");

	self.previousAirVelocity = (0, 0, 0);

	while (true)
	{
		wait 0.05;

		if (!isDefined(self.isBhopping))
			self.isBhopping = false;

		if (!self isOnGround() && self jumpButtonPressed())
		{
			self.isBhopping = true;
			self.previousAirVelocity = self getVelocity();
		}
		if (self.isBhopping && !self jumpButtonPressed() || self getStance() == "prone")
			self.isBhopping = false;
		if (self.isBhopping && self isOnGround())
		{
			velocity = self.previousAirVelocity - self getVelocity();
			self setVelocity(self getVelocity() + (velocity[0], velocity[1], 200));
		}
	}
}
