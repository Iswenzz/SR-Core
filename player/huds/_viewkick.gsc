#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("spawn", ::onSpawn);
}

needsViewkick()
{
	return !self.pers["viewkick"] && !self isDefrag();
}

onSpawn()
{
	self.pers["viewkick"] = IfUndef(self.pers["viewkick"], true);
	viewkick = self.pers["viewkick"];

	if (self needsViewkick())
	{
		self setClientDvars(
			"bg_viewKickMax", 90,
			"bg_viewKickMin", 5,
			"bg_viewKickRandom", 0.4,
			"bg_viewKickScale", 0.2
		);
		self.pers["viewkick"] = true;
	}
	else
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
