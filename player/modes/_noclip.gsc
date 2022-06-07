#include sr\sys\_events;

main()
{
	event("connect", ::noclip);
}

noclip()
{
	self endon("disconnect");
	self.noclip = false;

	if (!self sr\sys\_admins::isGroup("masteradmin"))
		return;

	while (true)
	{
		while (!self.noclip)
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
