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

	while (true)
	{
		self waittill("grenade_fire", entity, weapName);

		if (weapName != insertionItem)
			continue;

		self giveMaxAmmo(insertionItem);
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
		entity thread flareFx();

		self iPrintln("^2Insertion at " + spawn.origin);

		if (level.dvar["insertion_spawn"])
			self.insertionSpawn = spawn;
	}
}

flareFx()
{
	while (isDefined(self))
	{
		playFxOnTag(level.gfx["startnstop"], self, "tag_fx");
		wait 0.2;
	}
}
