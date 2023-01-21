#include sr\sys\_events;

main()
{
	event("spawn", ::spawn);
}

spawn()
{
	if (!isDefined(self.pers["viewkick"]))
		self.pers["viewkick"] = true;

	if (!self.pers["viewkick"] && self.sr_mode != "Defrag")
	{
		self setClientDvars(
			"bg_viewKickMax", 90,
			"bg_viewKickMin", 5,
			"bg_viewKickRandom", 0.4,
			"bg_viewKickScale", 0.2
		);
		self.pers["viewkick"] = true;
	}
	else if (self.pers["viewkick"] && self.sr_mode == "Defrag")
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
