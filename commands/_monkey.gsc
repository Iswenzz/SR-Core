#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("monkey", "player", ::cmd_Monkey, "Roll in a Monkey Ball");
}

cmd_Monkey(args)
{
	if (self sr\core\_minigames::isInOtherQueue("monkey"))
		return;

	if (!self sr\core\_minigames::isInQueue("monkey"))
		sr\minigames\_monkey::join();
	else
		sr\minigames\_monkey::leave();
}
