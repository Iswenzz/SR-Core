#include sr\sys\_events;

main()
{
	menu("sr_welcome", "message", ::menu_WelcomeMessage);
}

menu_WelcomeMessage(arg)
{
	self endon("disconnect");

	if (self.pers["team"] != "allies")
		return;

	group = self sr\sys\_admins::getGroupString();
	geo = self getGeoLocation(2);

	sr\sys\_admins::message(fmt("^2Welcome ^7%s ^7%s ^7from ^1%s", group, self.name, geo));
}
