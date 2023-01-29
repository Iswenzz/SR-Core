#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("connect", ::playedTime);
	event("connected", ::updateMenuPT);
}

playedTime()
{
	self endon("connect");
	self endon("disconnect");

	while (true)
	{
		if (!isDefined(self.timePlayed))
			self.timePlayed = getTime();

		time = originToTime(getTime() - self.timePlayed);
		self setStat(2629, self getStat(2629) + time.min);
		self.timePlayed = getTime();

		wait 60;
	}
}

updateMenuPT()
{
	self setClientDvar("sr_info_timePlayed", self getStat(2629));
}
