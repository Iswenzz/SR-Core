#include sr\sys\_events;
#include sr\player\modes\_main;

main()
{
	event("spawn", ::onSpawn);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!isInMode("practise") && !isInMode("debug"))
		return;

	while (true)
	{
		while (self fragButtonPressed())
		{
			wait 0.05;
			speed = Ternary(self jumpButtonPressed(), 300, 70);
			origin = self getOrigin() + (anglesToForward(self getPlayerAngles()) * speed);

			if (!isDefined(self.linker))
			{
				self.linker = spawn("script_origin", self getOrigin());
				self linkTo(self.linker);
			}
			self.linker moveTo(origin, 0.05);
		}
		if (isDefined(self.linker) && self jumpButtonPressed())
		{
			self unlink();
			self.linker delete();
		}
		wait 0.1;
	}
}
