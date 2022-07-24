#include sr\utils\_common;
#include sr\game\_perks;

weapons(list)
{
	waitMapLoad();
	level.defragStartWeapons = strTok(list, ";");
}

perks(list)
{
	waitMapLoad();
	level.mapPerks = strTok(list, ";");
}

triggerSection(id, origin, width, height, callback)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "defrag_section";
	trigger.radius = width;
	trigger.callback = callback;
	trigger.id = id;
}

triggerWeapon(id, origin, width, height, weapon, ammo)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "defrag_weapon";
	trigger.radius = width;
	trigger.weapon = weapon;
	trigger.ammo = ammo;
	trigger.id = id;
}

triggerPerk(id, origin, width, height, perk, time)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "defrag_perk";
	trigger.radius = width;
	trigger.perk = perk;
	trigger.time = time;
	trigger.id = id;
}

switchToDefragWeapon(name)
{
	self switchToWeapon(level.defragWeapons[name]);
}

takeDefragWeapon(name)
{
	self takeWeapon(level.defragWeapons[name]);
}

takeAllPerks(name)
{
	self.perks = [];
}

takeDefragPerk(name)
{
	self playerRemovePerk(name);
}

giveDefragWeapon(name, ammo)
{
	weapon = level.defragWeapons[name];

	self giveWeapon(weapon);
	self switchToWeapon(weapon);

	if (isDefined(ammo))
		self setWeaponAmmoClip(weapon, ammo);
}

giveDefragPerk(name, time)
{
	self playerSetPerk(name);

	if (isDefined(time))
	{
		wait time;
		self takeDefragPerk(name);
	}
}
