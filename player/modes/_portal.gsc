#include sr\sys\_events;
#include sr\player\modes\_main;

main()
{
	createMode("portal");

	event("spawn", ::onSpawn);
	event("death", ::onDeath);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!IsInMode("portal"))
		return;

	self waittill("speedrun");
	self.huds["speedrun"]["name"] setText("^5Portal");

	self allowAds(true);

	weapon = level.portalgun;
	self takeAllWeapons();
	self giveWeapon(weapon);
	self setSpawnWeapon(weapon);
	self giveMaxAmmo(weapon);
}

onDeath()
{
	self sr\libs\portal\_hud::updateHud("none");
}
