#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("spawn", ::onSpawn);
}

enableViewkick()
{
	if (self.pers["viewkick"])
		return false;
	return !self isDefrag();
}

disableViewkick()
{
	if (!self.pers["viewkick"])
		return false;
	return self isDefrag();
}

onSpawn()
{
	self.pers["viewkick"] = IfUndef(self.pers["viewkick"], true);

	if (self enableViewkick())
	{
		self setClientDvars(
			"bg_viewKickMax", 90,
			"bg_viewKickMin", 5,
			"bg_viewKickRandom", 0.4,
			"bg_viewKickScale", 0.2
		);
		self.pers["viewkick"] = true;
	}
	else if (self disableViewkick())
	{
		self setClientDvars(
			"bg_viewKickMax", 0,
			"bg_viewKickMin", 0,
			"bg_viewKickRandom", 0,
			"bg_viewKickScale", 0
		);
		self.pers["viewkick"] = false;
	}
}
