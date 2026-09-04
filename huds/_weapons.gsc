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

	self.prevWeaponAmmo = undefined;
	self.prevWeaponShown = undefined;

	while (true)
	{
		self.player = IfUndef(self getSpectatorClient(), self);

		ammo = IfUndef(self.player.scriptedAmmo, 0);
		shown = self.player isQ3() && !self.player isQ3W() && ammo < 100;

		if (!isDefined(self.prevWeaponAmmo) || ammo != self.prevWeaponAmmo)
			self.huds["weapon"] setValue(ammo);
		if (!isDefined(self.prevWeaponShown) || shown != self.prevWeaponShown)
			self.huds["weapon"].alpha = Ternary(shown, 1, 0);

		self.prevWeaponAmmo = ammo;
		self.prevWeaponShown = shown;

		wait 0.05;
	}
}

create()
{
	self.huds["weapon"] = addHud(self, -100, 0, 0, "right", "bottom", 1.4);
	self.huds["weapon"].font = "objective";
	self.huds["weapon"] setValue(0);
}

clear()
{
	if (isDefined(self.huds["weapon"]))
		self.huds["weapon"] destroy();
}
