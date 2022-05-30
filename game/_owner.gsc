#include sr\game\_menu;

main()
{
    level.sr_menu["owner"] = [];

    // Main
	main = menu("Main", "owner", "main");
	option(main, "Message", 		::cmd_Message);
	option(main, "God", 			::cmd_God);
	option(main, "Epic Speed", 		::cmd_Speed, 500);
	option(main, "Q3", 				::cmd_Q3);
	option(main, "Unlimited Ammo", 	::cmd_UAmmo);
	option(main, "Can Damage", 		::cmd_CanDamage);

	// Weapons
	weapons = menu("Weapons", "owner", "weapon");
	option(weapons, "Frag", 		::cmd_Weapon, "frag_grenade_mp");
	option(weapons, "Smoke", 		::cmd_Weapon, "smoke_grenade_mp");
	option(weapons, "Flash", 		::cmd_Weapon, "flash_grenade_mp");
	option(weapons, "Dance", 		::cmd_Weapon, "fortnite_mp");

	// Redirect
	redirect = menu("Redirect", "owner", "redirect");
	option(redirect, "SR-BR", 		::cmd_Redirect, "iswenzz.com:28964");
	option(redirect, "SR-DR",  		::cmd_Redirect, "iswenzz.com:28962");
	option(redirect, "FNRP", 		::cmd_Redirect, "fr1.fnrp-servers.com:28940");
	option(redirect, "3xP CJ", 		::cmd_Redirect, "c.3xP-Clan.com:1337");
}

event()
{
    self thread onMenuResponse("owner", "shop_mp");
}

cmd_God(arg)
{
	self sr\sys\_admins::command("god");
}

cmd_Redirect(arg)
{
	self sr\sys\_admins::command("redirect_all", arg);
}

cmd_Speed(arg)
{
	self sr\sys\_admins::command("g_speed", arg);
}

cmd_Q3(arg)
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

cmd_Weapon(arg)
{
	self giveWeapon(arg);
	self switchToWeapon(arg);

	self thread close();
	self notify("sr_menu_close");
}

cmd_UAmmo(arg)
{
	self sr\sys\_admins::command("cmd_UAmmo", "");
}

cmd_CanDamage(arg)
{
	self sr\sys\_admins::command("candamage", "");
}

cmd_Message(arg)
{
	message = IfUndef(getDvar("message"), "XD");
	iPrintLnBold(message);
}
