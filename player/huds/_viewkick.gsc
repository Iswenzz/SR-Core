#include sr\sys\_events;

main()
{
	event("spawn", ::spawn);
}

spawn()
{
	wait 0.05;

	if (!isDefined(self.viewKick))
		self.viewKick = true;

	if (!self.viewKick && self.sr_mode != "Defrag")
	{
		self setClientDvars(
			"bg_viewKickMax", 90,
			"bg_viewKickMin", 5,
			"bg_viewKickRandom", 0.4,
			"bg_viewKickScale", 0.2
		);
		self.viewKick = true;
	}
	else if (self.viewKick && self.sr_mode == "Defrag")
	{
		self setClientDvars(
			"bg_viewKickMax", 0,
			"bg_viewKickMin", 0,
			"bg_viewKickRandom", 0,
			"bg_viewKickScale", 0
		);
		self.viewKick = false;
	}
}
