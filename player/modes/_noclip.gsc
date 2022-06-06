#include sr\sys\_events;

main()
{
	event("connect", ::noclip);
}

noclip()
{
	self endon("disconnect");

	while (true)
	{
		while (!isDefined(self.noclip))
			wait 1;

		while (self fragButtonPressed())
		{
			speed = Ternary(self useButtonPressed(), 300, 70);
			origin = self getOrigin() + (anglesToForward(self getPlayerAngles()) * speed);
			self moveTo(origin, 0.05);
		}
		wait 0.1;
	}
}
