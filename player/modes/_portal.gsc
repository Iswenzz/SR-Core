#include sr\sys\_events;
#include sr\player\modes\_main;

main()
{
	createMode("portal");

	event("spawn", ::portal);
	event("death", ::death);
}

portal()
{
	self endon("disconnect");
	self endon("death");

	if (!IsInMode("portal"))
		return;

	self waittill("speedrun_hud");
	self.run = "Portal";
	self.huds["speedrun"]["name"] setText("^5Portal");

	self allowAds(true);

	weapon = level.portalgun;
	self takeAllWeapons();
	self giveWeapon(weapon);
	self setSpawnWeapon(weapon);
	self giveMaxAmmo(weapon);
}

death()
{
	self sr\libs\portal\_hud::updateHud("none");
}
