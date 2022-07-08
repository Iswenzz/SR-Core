#include sr\sys\_events;
#include sr\player\modes\_main;

main()
{
	createMode("noclip");

	event("spawn", ::noclip);
}

noclip()
{
	self endon("disconnect");
	self endon("death");

	if (!isInMode("noclip") || !self sr\sys\_admins::isRole("masteradmin"))
		return;

	self waittill("speedrun_hud");
	self.run = "Noclip";
	self.huds["speedrun"]["name"] setText("^3Noclip");

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
