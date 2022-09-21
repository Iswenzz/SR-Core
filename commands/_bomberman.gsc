#include sr\sys\_file;
#include sr\sys\_admins;
#include sr\game\minigames\_main;
#include sr\game\minigames\_bomberman;
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
	if (self isInOtherQueue("bomberman"))
		return;
	if (!self isInQueue("bomberman"))
		join();
	else
		leave();
}

cmd_BombermanSpawn(args)
{
	level.bombermanOrigin = self.origin;
	level.bombermanAllowed = true;
	self pm("Placed bomberman origin");
}
