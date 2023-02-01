#include sr\sys\_dvar;
#include sr\sys\_events;
#include sr\utils\_math;
#include sr\utils\_common;

main()
{
	level.pickup_maxdist = 100;
	level.pickup_object_distance = 40;
}

pickup(arg)
{
	if (!self sr\sys\_admins::isRole("owner"))
		return;
	if (self getCurrentWeapon() != level.portalgun)
		return;
	if (self isOnLadder() || self isMantling() || self.throwingGrenade)
		return;
}
