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

createAmmo(id, origin, width, height, weapon, ammo)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "q3_ammo";
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

createHealth(id, origin, width, height, health)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "q3_health";
	trigger.radius = width;
	trigger.health = health;
	trigger.id = id;

	return trigger;
}

createArmor(id, origin, width, height, armor)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "q3_armor";
	trigger.radius = width;
	trigger.armor = armor;
	trigger.id = id;

	return trigger;
}

createTeleporter(id, origin, width, height, destination)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "q3_teleporter";
	trigger.radius = width;
	trigger.target = destination;
	trigger.id = id;

	trigger thread sr\core\_q3::teleporter();
	return trigger;
}

setWeapons(list)
{
	level.q3StartWeapons = strTok(list, ";");
}

setAmmo(count)
{
	level.q3StartAmmo = count;
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
}

giveAmmo(name, ammo)
{
	self sr\core\_q3::playerAddAmmo(name, ammo);
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

giveHealth(amount)
{
	self sr\core\_q3::playerAddHealth(amount);
}

giveArmor(amount)
{
	self sr\core\_q3::playerAddArmor(amount);
}

takeArmor()
{
	self.q3Armor = 0;
}
