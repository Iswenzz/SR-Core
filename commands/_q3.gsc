#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("q3_mode",   "owner", ::cmd_Mode,   "Toggle q3 mode");
	cmd("q3_perk",   "owner", ::cmd_Perk,   "Spawn a q3 perk");
	cmd("q3_weapon", "owner", ::cmd_Weapon, "Spawn a q3 weapon");
}

cmd_Mode(args)
{
	if (self sr\core\_modes::isInOtherMode("q3"))
		return;

	self sr\core\_modes::toggleMode("q3");
	self suicide();

	self pm(Ternary(self.modes["q3"], "^3Q3 mode enabled!", "^1Q3 mode disabled!"));
}

cmd_Weapon(args)
{
	if (args.size < 1)
		return self pm("Usage: !q3_weapon <weapon> <ammo>");

	weapon = args[0];
	ammo = IfUndef(ToInt(args[1]), 999999);

	trigger = spawn("trigger_radius", self.origin + (0, 0, 60), 0, 50, 50);
	trigger.radius = 50;
	trigger.targetname = "q3_weapon";
	trigger.weapon = weapon;
	trigger.ammo = ammo;
	trigger.id = ToString(randomInt(999999));

	trigger thread sr\core\_q3::triggerWeapon();
}

cmd_Perk(args)
{
	if (args.size < 1)
		return self pm("Usage: !q3_perk <perk> <time>");

	perk = args[0];
	time = IfUndef(ToInt(args[1]), 0);

	trigger = spawn("trigger_radius", self.origin + (0, 0, 60), 0, 50, 50);
	trigger.radius = 50;
	trigger.targetname = "q3_perk";
	trigger.perk = perk;
	trigger.time = time;
	trigger.id = ToString(randomInt(999999));

	trigger thread sr\core\_q3::triggerPerk();
}
