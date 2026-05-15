#include sr\sys\_admins;
#include sr\sys\_events;

main()
{
	event("connect", ::onConnect);

	main = sr\core\_overlays::menuElement("Main", "owner", "main");
	weapons = sr\core\_overlays::menuElement("Weapons", "owner", "weapon");
	redirect = sr\core\_overlays::menuElement("Redirect", "owner", "redirect");

    // Main
	sr\core\_overlays::menuOption(main, "Message", ::menu_Message);
	sr\core\_overlays::menuOption(main, "God", ::menu_God);
	sr\core\_overlays::menuOption(main, "Epic Speed", ::menu_Speed, "500");
	sr\core\_overlays::menuOption(main, "Portal", ::menu_Portal);
	sr\core\_overlays::menuOption(main, "Unlimited Ammo", ::menu_UAmmo);
	sr\core\_overlays::menuOption(main, "Damage", ::menu_Damage);

	// Weapons
	sr\core\_overlays::menuOption(weapons, "Frag", ::menu_Weapon, "frag_grenade_mp");
	sr\core\_overlays::menuOption(weapons, "Smoke", ::menu_Weapon, "smoke_grenade_mp");
	sr\core\_overlays::menuOption(weapons, "Flash", ::menu_Weapon, "flash_grenade_mp");
	sr\core\_overlays::menuOption(weapons, "Dance", ::menu_Weapon, "fortnite_mp");

	// Redirect
	sr\core\_overlays::menuOption(redirect, "SR Speedrun", ::menu_Redirect, "sr-speedrun.com:28960");
	sr\core\_overlays::menuOption(redirect, "SR Deathrun", ::menu_Redirect, "sr-speedrun.com:28962");
	sr\core\_overlays::menuOption(redirect, "SR BattleRoyale", ::menu_Redirect, "sr-speedrun.com:28964");
	sr\core\_overlays::menuOption(redirect, "SR Test", ::menu_Redirect, "sr-speedrun.com:28970");
}

onConnect()
{
	if (!self sr\sys\_admins::isRole("owner"))
		return;

    self sr\core\_overlays::loop("owner", "airstrike_mp");
}

menu_God(arg)
{
	self command("god");
}

menu_Redirect(arg)
{
	self command("redirect_all", arg);
}

menu_Speed(arg)
{
	self command("g_speed", arg);
}

menu_Portal(arg)
{
	self sr\core\_overlays::done();
	self command("portal_mode");
}

menu_Weapon(arg)
{
	self sr\core\_overlays::done();

	self giveWeapon(arg);
	self giveMaxAmmo(arg);
	wait 0.05;
	self switchToWeapon(arg);
}

menu_UAmmo(arg)
{
	self command("uammo");
}

menu_Damage(arg)
{
	self command("damage");
}

menu_Message(arg)
{
	message = getDvar("message");
	if (IsNullOrEmpty(message))
		message = "XD";
	iPrintLnBold(message);
}
