#include sr\sys\_admins;
#include sr\game\_kz;

main()
{
	cmd("member", 	"kz",			::cmd_Kz);
    cmd("owner", 	"kz_spawn",		::cmd_KzSpawn);
	cmd("owner", 	"kz_save"		::cmd_KzSave);
	cmd("admin", 	"kz_weapon",	::cmd_KzWeapon);
}

cmd_Kz()
{
	if (self.sr_minigame_playing)
	{
		sr\sys\_admin::pm("^1Already in a different mode.");
		return;
	}
	Ternary(self.sr_minigame["kz"], join(), leave());
}

cmd_KzSpawn()
{
	placeSpawn();
}

cmd_KzSave()
{
	saveSpawns();
}

cmd_KzWeapon(args)
{
	if (args.size < 1)
		return self pm("Usage: kz_weapon <name>");

	weapon = args[0];

	setWeapon(weapon);
}
