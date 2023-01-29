#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("spawn", ::onSpawn);
}

onSpawn()
{
	if (!level.dvar["insertion"])
		return;

	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	insertionItem = "claymore_mp";
	self giveWeapon(insertionItem);
	self giveMaxAmmo(insertionItem);

	wait 0.1;

	while (self isReallyAlive())
	{
		self waittill("grenade_fire", entity, weapName);

		if (weapName != insertionItem)
			continue;

		self giveMaxAmmo(insertionItem);

		entity.flareloop = false;
		entity stopLoopSound();
		entity waitTillNotMoving();

		spawn = spawnStruct();
		spawn.origin = entity.origin;
		spawn.angle = entity.angles;

		if (!self isOnGround() || distance(self.origin, spawn.origin) > 48)
		{
			self iPrintln("^1You can't use insertion here");
			entity delete();
			continue;
		}

		entity.flareloop = true;
		entity thread flareFx();

		self iPrintln("^2Insertion at " + spawn.origin);

		if (level.dvar["insertion_spawn"])
			self.insertionSpawn = spawn;
	}
}

flareFx()
{
	self endon("disconnect");

	while (isDefined(self))
	{
		playFxOnTag(level.fx["startnstop"], self, "tag_fx");
		wait 0.2;
	}
}
