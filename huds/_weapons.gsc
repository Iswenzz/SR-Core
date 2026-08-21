#include sr\sys\_events;
#include sr\utils\_common;
#include sr\utils\_hud;

main()
{
	event("spawn", ::hud);
	event("spectator", ::hud);
	event("death", ::clear);
}

hud()
{
	self endon("spawned");
	self endon("spectator");
	self endon("death");
	self endon("disconnect");

	self clear();
	self create();

	self.prevAmmo = 0;

	while (true)
	{
		self.player = IfUndef(self getSpectatorClient(), self);

		self.scriptedAmmo = self.player.scriptedAmmo;
		if (self.scriptedAmmo != self.prevAmmo)
			self.huds["weapon"] setValue(self.scriptedAmmo);
		self.huds["weapon"].alpha = self.scriptedAmmo <= 100;

		wait 0.05;

        self.prevAmmo = self.scriptedAmmo;
	}
}

create()
{
	self.huds["weapon"] = addHud(self, -100, 0, 1, "right", "bottom", 1.4);
	self.huds["weapon"].font = "objective";
}

clear()
{
	if (isDefined(self.huds["weapon"]))
		self.huds["weapon"] destroy();
}
