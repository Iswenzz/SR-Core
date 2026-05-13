#include sr\sys\_events;

main()
{
	sr\core\_modes::createMode("portal");

	event("spawn", ::onSpawn);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!sr\core\_modes::IsInMode("portal"))
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
