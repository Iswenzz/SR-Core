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

		weapon = self.player getCurrentWeapon();
		shown = self.player isQ3() && !self.player isQ3W() && isQ3Item(weapon);
		ammo = 0;
		if (shown)
			ammo = self.player getWeaponAmmoClip(weapon);

		if (!isDefined(self.prevWeaponAmmo) || ammo != self.prevWeaponAmmo)
			self.huds["weapon"] setValue(ammo);
		if (!isDefined(self.prevWeaponShown) || shown != self.prevWeaponShown)
			self.huds["weapon"].alpha = Ternary(shown, 1, 0);

		self.prevWeaponAmmo = ammo;
		self.prevWeaponShown = shown;

		wait 0.05;
	}
}

isQ3Item(weapon)
{
	names = getArrayKeys(level.q3Weapons);
	for (i = 0; i < names.size; i++)
	{
		if (isDefined(level.q3Weapons[names[i]]) && level.q3Weapons[names[i]] == weapon)
			return true;
	}
	return false;
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
