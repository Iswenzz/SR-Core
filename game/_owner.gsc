#include sr\game\_menu;

main()
{
    level.sr_menu["owner"] = [];

    // Main
	option("Message", 			"owner", "main", ::cmd_Message, undefined);
	option("God", 				"owner", "main", ::cmd_God, undefined);
	option("Epic Speed", 		"owner", "main", ::cmd_Speed, 500);
	option("Q3", 				"owner", "main", ::cmd_Q3, undefined);
	option("Unlimited Ammo", 	"owner", "main", ::cmd_UAmmo, undefined);
	option("Can Damage", 		"owner", "main", ::cmd_CanDamage, undefined);

	// Weapons
	menu("Weapons", 			"owner", "weapon");
	option("Frag", 				"owner", "weapon", ::cmd_Weapon, "frag_grenade_mp");
	option("Smoke", 			"owner", "weapon", ::cmd_Weapon, "smoke_grenade_mp");
	option("Flash", 			"owner", "weapon", ::cmd_Weapon, "flash_grenade_mp");
	option("Dance", 			"owner", "weapon", ::cmd_Weapon, "fortnite_mp");

	// Redirect
	menu("Redirect", 			"owner", "redirect");
	option("Sr- BattleRoyale", 	"owner", "redirect", ::cmd_Redirect, "iswenzz.com:28964");
	option("Sr- Deathrun", 		"owner", "redirect", ::cmd_Redirect, "iswenzz.com:28962");
	option("FNRP", 				"owner", "redirect", ::cmd_Redirect, "fr1.fnrp-servers.com:28940");
	option("3xP CJ", 			"owner", "redirect", ::cmd_Redirect, "c.3xP-Clan.com:1337");
}

event()
{
    self thread onMenuResponse("owner", "shop_mp");
}

cmd_God(args)
{
	self sr\sys\_admins::command("god");
}

cmd_Redirect(args)
{
	self sr\sys\_admins::command("redirect_all", args);
}

cmd_Speed(args)
{
	self sr\sys\_admins::command("g_speed", args);
}

cmd_Q3(args)
{
	self sr\sys\_admins::command("practise");
	self sr\sys\_admins::command("knockback");

	self takeAllWeapons();
	self giveWeapon("gl_ak47_mp");
	self giveWeapon("gl_g3_mp");
	self switchToWeapon("gl_ak47_mp");

	self close();
	self notify("sr_menu_close");
}

cmd_Weapon(args)
{
	self giveWeapon(args);
	self switchToWeapon(args);

	self thread close();
	self notify("sr_menu_close");
}

cmd_UAmmo(args)
{
	self sr\sys\_admins::command("cmd_UAmmo", "");
}

cmd_CanDamage(args)
{
	self sr\sys\_admins::command("candamage", "");
}

cmd_Message(args)
{
	message = IfUndef(self getDvar("message"), "XD")
	iPrintLnBold(message);
}
