#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("connect", ::playedTime);
}

playedTime()
{
	self endon("disconnect");

	self thread updateMenuPT();

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
	wait 0.5;

	time = originToTime(getTime() - self.timePlayed);
	self setClientDvar("sr_info_timePlayed", self getStat(2629) + time.min);
}
