#include sr\utils\_common;

weapons(list)
{
	level.q3StartWeapons = strTok(list, ";");
}

perks(list)
{
	level.mapPerks = strTok(list, ";");
}

triggerSection(id, origin, width, height, callback)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "q3_section";
	trigger.radius = width;
	trigger.callback = callback;
	trigger.id = id;

	return trigger;
}

triggerWeapon(id, origin, width, height, weapon, ammo)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "q3_weapon";
	trigger.radius = width;
	trigger.weapon = weapon;
	trigger.ammo = ammo;
	trigger.id = id;

	return trigger;
}

triggerPerk(id, origin, width, height, perk, time)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "q3_perk";
	trigger.radius = width;
	trigger.perk = perk;
	trigger.time = time;
	trigger.id = id;

	return trigger;
}

switchToQ3Weapon(name)
{
	self switchToWeapon(level.q3Weapons[name]);
}

takeQ3Weapon(name)
{
	self takeWeapon(level.q3Weapons[name]);
}

takeAllPerks()
{
	self.perks = [];
}

takeQ3Perk(id)
{
	self sr\core\_perks::playerRemovePerk(id);
}

giveQ3Weapon(name, ammo)
{
	weapon = level.q3Weapons[name];

	self giveWeapon(weapon);
	self switchToWeapon(weapon);

	if (isDefined(ammo))
		self setWeaponAmmoClip(weapon, ammo);
}

giveQ3Perk(id, time)
{
	self sr\core\_perks::playerSetPerk(id);

	if (isDefined(time))
	{
		wait time;
		self takeQ3Perk(id);
	}
}
