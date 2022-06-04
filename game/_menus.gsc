#include sr\sys\_events;

main()
{
	menu("sr_welcome", "message", ::menu_WelcomeMessage);
}

menu_WelcomeMessage(arg)
{
	self thread speedrun\_main::connectMessages();
}
