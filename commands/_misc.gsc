#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
    cmd("about",   "player", ::cmd_About, "Display the about menu");
    cmd("discord", "player", ::cmd_Discord, "Display the server Discord");
    cmd("emojis",  "player", ::cmd_Emojis,  "Display the client emojis");
    cmd("website", "player", ::cmd_Website, "Display the server website");
}

cmd_About(args)
{
	self openMenu("about_page_1");
}

cmd_Discord(args)
{
	discord = "Join SR Discord: ^5discord.gg/76aHfGF";

	if (self isRole("member"))
    	self message(discord);
	else
		self pm(discord);
}

cmd_Website(args)
{
	discord = "Vist SR Website: ^5sr-speedrun.com";

	if (self isRole("member"))
    	self message(discord);
	else
		self pm(discord);
}

cmd_Emojis(args)
{
	emojis = strTok("africa;angry;bored;cash;clown;cold;cowboy;down;feet;fire;happy;heart;huff;huh;imp;joy;monkey;neutral;noevil;omg;palm;pensive;pls;rage;rofl;rose;sad;sh;shit;skull;skull2;skull3;sus;think;uk;up;weary;wizard;wtf;wtf2;yawn", ";");

	self pm("Emojis available on ^5IW3SR ^7client:");
	for (i = 0; i < emojis.size; i++)
	{
		self pm(fmt(":%s: %s", emojis[i], emojis[i]));
		wait 0.05;
	}
}
