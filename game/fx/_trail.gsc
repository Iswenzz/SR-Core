#include sr\sys\_events;

main()
{
	event("spawn", ::trail);
}

trail()
{
	self endon("death");
	self endon("disconnect");

	if (!self sr\sys\_admins::isVIP())
		return;

	while (isDefined(self.vip_trail) && self.vip_trail)
	{
		self.trail = spawn("script_model", self.origin);
		self.trail setModel("tag_origin");
		self.trail linkTo(self);

		if (self.vip_trail)
			playFXOnTag(level.fx["viptrail" + self.vip_trail], self.trail, "tag_origin");
		wait 0.05;
	}
}
