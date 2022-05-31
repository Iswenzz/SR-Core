#include sr\game\_menu;

main()
{
    level.sr_menu["owner"] = [];

    // Main
	main = menu("Main", "owner", "main");
	option(main, "Message", 		::menu_Message);
	option(main, "God", 			::menu_God);
	option(main, "Epic Speed", 		::menu_Speed, 500);
	option(main, "Q3", 				::menu_Q3);
	option(main, "Unlimited Ammo", 	::menu_UAmmo);
	option(main, "Can Damage", 		::menu_CanDamage);

	// Weapons
	weapons = menu("Weapons", "owner", "weapon");
	option(weapons, "Frag", 		::menu_Weapon, "frag_grenade_mp");
	option(weapons, "Smoke", 		::menu_Weapon, "smoke_grenade_mp");
	option(weapons, "Flash", 		::menu_Weapon, "flash_grenade_mp");
	option(weapons, "Dance", 		::menu_Weapon, "fortnite_mp");

	// Redirect
	redirect = menu("Redirect", "owner", "redirect");
	option(redirect, "SR-BR", 		::menu_Redirect, "iswenzz.com:28964");
	option(redirect, "SR-DR",  		::menu_Redirect, "iswenzz.com:28962");
	option(redirect, "FNRP", 		::menu_Redirect, "fr1.fnrp-servers.com:28940");
	option(redirect, "3xP CJ", 		::menu_Redirect, "c.3xP-Clan.com:1337");
}

event()
{
    self thread onMenuResponse("owner", "shop_mp");
}

menu_God(arg)
{
	self sr\sys\_admins::command("god");
}

menu_Redirect(arg)
{
	self sr\sys\_admins::command("redirect_all", arg);
}

menu_Speed(arg)
{
	self sr\sys\_admins::command("g_speed", arg);
}

menu_Q3(arg)
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

menu_Weapon(arg)
{
	self giveWeapon(arg);
	self switchToWeapon(arg);

	self thread close();
	self notify("sr_menu_close");
}

menu_UAmmo(arg)
{
	self sr\sys\_admins::command("uammo", "");
}

menu_CanDamage(arg)
{
	self sr\sys\_admins::command("candamage", "");
}

menu_Message(arg)
{
	message = IfUndef(getDvar("message"), "XD");
	iPrintLnBold(message);
}
