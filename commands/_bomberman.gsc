#include sr\sys\_file;
#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("player", 	"bomberman",		::cmd_Bomberman);
	cmd("owner", 	"bomberman_spawn",	::cmd_BombermanSpawn);
}

cmd_Bomberman(args)
{
	if (!level.bombermanAllowed)
	{
		self pm("^3Bomberman ^7is not activated!");
		return;
	}
	if (self sr\core\_minigames::isInOtherQueue("bomberman"))
		return;

	if (!self sr\core\_minigames::isInQueue("bomberman"))
		sr\minigames\_bomberman::join();
	else
		sr\minigames\_bomberman::leave();
}

cmd_BombermanSpawn(args)
{
	level.bombermanOrigin = self.origin;
	level.bombermanAllowed = true;
	self pm("Placed bomberman origin");
}
