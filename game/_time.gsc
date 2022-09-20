#include sr\sys\_events;
#include sr\utils\_common;

main()
{
	event("connect", ::playedTime);
}

playedTime()
{
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
