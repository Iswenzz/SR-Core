#include sr\sys\_events;
#include sr\player\modes\_main;

main()
{
	createMode("defrag");

	event("spawn", ::defrag);
}

defrag()
{
	self endon("disconnect");
	self endon("death");

	if (!IsInMode("defrag"))
		return;

	self waittill("speedrun_hud");
	self.run = "Defrag";
	self.huds["speedrun"]["name"] setText("^3Defrag");

	self takeAllWeapons();
	self giveWeapon("gl_ak47_mp");
	self giveWeapon("gl_g3_mp");
	self setSpawnWeapon("gl_ak47_mp");

	self thread sr\player\_bhop::loop();
}
