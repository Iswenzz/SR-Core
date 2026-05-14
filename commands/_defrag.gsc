#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("defrag_mode",   "owner", ::cmd_DefragMode,   "Toggle defrag mode");
	cmd("defrag_perk",   "owner", ::cmd_DefragPerk,   "Spawn a defrag perk");
	cmd("defrag_weapon", "owner", ::cmd_DefragWeapon, "Spawn a defrag weapon");
}

cmd_DefragMode(args)
{
	if (self.sr_mode == "Defrag" || self sr\core\_modes::isInOtherMode("defrag"))
		return;

	self sr\core\_modes::toggleMode("defrag");
	self suicide();

	self pm(Ternary(self.modes["defrag"], "^3Defrag mode enabled!", "^1Defrag mode disabled!"));
}

cmd_DefragWeapon(args)
{
	if (args.size < 1)
		return self pm("Usage: !defrag_weapon <weapon> <ammo>");

	weapon = args[0];
	ammo = IfUndef(ToInt(args[1]), 0);

	trigger = spawn("trigger_radius", self.origin + (0, 0, 60), 0, 50, 50);
	trigger.radius = 50;
	trigger.targetname = "defrag_weapon";
	trigger.weapon = weapon;
	trigger.ammo = ammo;
	trigger.id = ToString(randomInt(999999));

	trigger thread sr\core\_defrag::triggerWeapon();
}

cmd_DefragPerk(args)
{
	if (args.size < 1)
		return self pm("Usage: !defrag_perk <perk> <time>");

	perk = args[0];
	time = IfUndef(ToInt(args[1]), 0);

	trigger = spawn("trigger_radius", self.origin + (0, 0, 60), 0, 50, 50);
	trigger.radius = 50;
	trigger.targetname = "defrag_weapon";
	trigger.perk = perk;
	trigger.time = time;
	trigger.id = ToString(randomInt(999999));

	trigger thread sr\core\_defrag::triggerPerk();
}
