weapons(list)
{
	weapons = strTok(list, "_");
}

triggerWeapon(origin, width, height, weapon, ammo)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "defrag_weapon";
	trigger.radius = width;
	trigger.weapon = weapon;
	trigger.ammo = ammo;
}

triggerPerk(origin, width, height, perk, time)
{
	trigger = spawn("trigger_radius", origin, 0, width, height);
	trigger.targetname = "defrag_perk";
	trigger.radius = width;
	trigger.perk = perk;
	trigger.time = time;
}
