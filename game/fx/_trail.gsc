#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("spawn", ::onSpawn);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	trail = self getCustomizeFx();

	if (!self sr\sys\_admins::isVIP() || !trail["id"])
		return;

	wait 0.05;
	playFXOnTag(level.gfx["viptrail" + trail["id"]], self, "tag_origin");
}
