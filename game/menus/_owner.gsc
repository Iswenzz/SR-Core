#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\game\menus\_main;

main()
{
    level.sr_menu["owner"] = [];

	event("connect", ::onConnect);

	main = menuElement("Main", "owner", "main");
	weapons = menuElement("Weapons", "owner", "weapon");
	redirect = menuElement("Redirect", "owner", "redirect");

    // Main
	menuOption(main, "Message", 		::menu_Message);
	menuOption(main, "God", 			::menu_God);
	menuOption(main, "Epic Speed", 		::menu_Speed, 500);
	menuOption(main, "Q3", 				::menu_Q3);
	menuOption(main, "Unlimited Ammo", 	::menu_UAmmo);
	menuOption(main, "Can Damage", 		::menu_CanDamage);

	// Weapons
	menuOption(weapons, "Frag", 		::menu_Weapon, "frag_grenade_mp");
	menuOption(weapons, "Smoke", 		::menu_Weapon, "smoke_grenade_mp");
	menuOption(weapons, "Flash", 		::menu_Weapon, "flash_grenade_mp");
	menuOption(weapons, "Dance", 		::menu_Weapon, "fortnite_mp");

	// Redirect
	menuOption(redirect, "SR-BR", 		::menu_Redirect, "iswenzz.com:28964");
	menuOption(redirect, "SR-DR",  		::menu_Redirect, "iswenzz.com:28962");
	menuOption(redirect, "FNRP", 		::menu_Redirect, "fr1.fnrp-servers.com:28940");
	menuOption(redirect, "3xP CJ", 		::menu_Redirect, "c.3xP-Clan.com:1337");
}

onConnect()
{
    self menuEvent("owner", "shop_mp");
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
