#include sr\sys\_events;

main()
{
	event("spawn", ::onSpawn);
}

onSpawn()
{
	self endon("spawned");
	self endon("death");
	self endon("disconnect");

	self.vip_trail = self getStat(986);

	if (!self sr\sys\_admins::isVIP() || !isDefined(self.vip_trail) || self.vip_trail < 1)
		return;

	playFXOnTag(level.gfx["viptrail" + self.vip_trail], self, "tag_origin");
}
