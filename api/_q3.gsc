#include sr\utils\_common;

createSection(id, origin, width, height, callback)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "q3_section";
	trigger.radius = width;
	trigger.callback = callback;
	trigger.id = id;

	return trigger;
}

createWeapon(id, origin, width, height, weapon, ammo)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "q3_weapon";
	trigger.radius = width;
	trigger.weapon = weapon;
	trigger.ammo = ammo;
	trigger.id = id;

	return trigger;
}

createPerk(id, origin, width, height, perk, time)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "q3_perk";
	trigger.radius = width;
	trigger.perk = perk;
	trigger.time = time;
	trigger.id = id;

	return trigger;
}

setWeapons(list)
{
	level.q3StartWeapons = strTok(list, ";");
}

setPerks(list)
{
	level.mapPerks = strTok(list, ";");
}

switchToWeapon(name)
{
	self switchToWeapon(level.q3Weapons[name]);
}

takeWeapon(name)
{
	self takeWeapon(level.q3Weapons[name]);
}

takePerk(id)
{
	self sr\core\_perks::playerRemovePerk(id);
}

takeAllPerks()
{
	self.perks = [];
}

giveWeapon(name, ammo)
{
	weapon = level.q3Weapons[name];

	self giveWeapon(weapon);
	self switchToWeapon(weapon);

	if (isDefined(ammo))
		self setWeaponAmmoClip(weapon, ammo);
}

givePerk(id, time)
{
	self sr\core\_perks::playerSetPerk(id);

	if (isDefined(time))
	{
		wait time;
		self takePerk(id);
	}
}
