#include sr\sys\_events;
#include sr\player\modes\_main;

main()
{
	createMode("portal");

	event("spawn", ::onSpawn);
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

	weapon = level.portalgun;
	self takeAllWeapons();
	self giveWeapon(weapon);
	self setSpawnWeapon(weapon);
	self giveMaxAmmo(weapon);
	self allowAds(true);
}
