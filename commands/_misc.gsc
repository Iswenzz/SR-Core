#include sr\sys\_admins;

main()
{
    cmd("player", 	"discord",      ::cmd_Discord);
	cmd("player", 	"requirement",  ::cmd_Requirement);
}

cmd_Discord()
{
    message("Join Sr- Discord: ^5discord.gg/76aHfGF");
}

cmd_Requirement()
{
    message("Check #sr-requirement channel in our discord: ^5discord.gg/76aHfGF");
}
