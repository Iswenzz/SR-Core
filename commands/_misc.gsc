#include sr\sys\_admins;

main()
{
    cmd("player", 	"discord",      ::cmd_Discord);
	cmd("player", 	"requirement",  ::cmd_Requirement);
}

cmd_Discord(args)
{
    message("Join Sr- Discord: ^5discord.gg/76aHfGF");
}

cmd_Requirement(args)
{
    message("Check #sr-requirement channel in our discord: ^5discord.gg/76aHfGF");
}
