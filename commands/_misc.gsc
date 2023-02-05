#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
    cmd("player", 	"discord",      ::cmd_Discord);
}

cmd_Discord(args)
{
	discord = "Join Sr- Discord: ^5discord.gg/76aHfGF";

	if (self isRole("member"))
    	self message(discord);
	else
		self pm(discord);
}
