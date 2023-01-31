#include sr\sys\_events;
#include sr\player\modes\_main;

main()
{
	createMode("defrag");

	event("spawn", ::onSpawn);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	if (!IsInMode("defrag"))
		return;

	self waittill("speedrun");
	self.huds["speedrun"]["name"] setText("^3Defrag");

	self takeAllWeapons();
	self giveWeapon("gl_ak47_mp");
	self giveWeapon("gl_g3_mp");
	self setSpawnWeapon("gl_ak47_mp");
}
