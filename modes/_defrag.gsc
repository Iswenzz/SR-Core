#include sr\sys\_events;

main()
{
	sr\core\_modes::createMode("defrag");

	event("spawn", ::onSpawn);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!sr\core\_modes::IsInMode("defrag"))
		return;

	self waittill("speedrun");
	self.huds["speedrun"]["name"] setText("^3Defrag");

	self takeAllWeapons();
	self giveWeapon("gl_ak47_mp");
	self giveWeapon("gl_g3_mp");
	self setSpawnWeapon("gl_ak47_mp");
}
