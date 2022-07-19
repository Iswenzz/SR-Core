#include sr\sys\_admins;
#include sr\sys\_events;
#include sr\game\menus\_main;

main()
{
	event("connect", ::onConnect);

	main = menuElement("Main", "owner", "main");
	weapons = menuElement("Weapons", "owner", "weapon");
	redirect = menuElement("Redirect", "owner", "redirect");

    // Main
	menuOption(main, "Message", 		::menu_Message);
	menuOption(main, "God", 			::menu_God);
	menuOption(main, "Epic Speed", 		::menu_Speed, "500");
	menuOption(main, "Knockback", 		::menu_Knockback);
	menuOption(main, "Portal", 			::menu_Portal);
	menuOption(main, "Unlimited Ammo", 	::menu_UAmmo);
	menuOption(main, "Damage", 			::menu_Damage);

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
	if (!self sr\sys\_admins::isRole("owner"))
		return;

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

menu_Knockback(arg)
{
	self sr\sys\_admins::command("practise");
	self sr\sys\_admins::command("knockback");

	self close();
}

menu_Portal(arg)
{
	self sr\sys\_admins::command("portal_mode");

	self close();
}

menu_Weapon(arg)
{
	self giveWeapon(arg);
	self giveMaxAmmo(arg);
	wait 0.05;
	self switchToWeapon(arg);

	self close();
}

menu_UAmmo(arg)
{
	self sr\sys\_admins::command("uammo");
}

menu_Damage(arg)
{
	self sr\sys\_admins::command("damage");
}

menu_Message(arg)
{
	message = getDvar("message");
	if (IsNullOrEmpty(message))
		message = "XD";
	iPrintLnBold(message);
}
