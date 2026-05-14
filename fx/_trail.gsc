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

	fx = self sr\core\_assets::getCustomizeFx();

	if (!self sr\sys\_admins::isVIP() || !isDefined(fx) || !fx["id"])
		return;

	wait 0.05;
	playFXOnTag(level.gfx["viptrail" + fx["id"]], self, "tag_origin");
}
