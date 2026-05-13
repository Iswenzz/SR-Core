#include sr\sys\_file;
#include sr\sys\_admins;
#include sr\utils\_common;

main()
{
	cmd("player", 		"killzone",		::cmd_Kz);
    cmd("adminplus", 	"kz_spawn",		::cmd_KzSpawn);
	cmd("adminplus", 	"kz_save",		::cmd_KzSave);
	cmd("admin", 		"kz_weapon",	::cmd_KzWeapon);
}

cmd_Kz(args)
{
	if (self sr\core\_minigames::isInOtherQueue("kz"))
		return;

	if (!self sr\core\_minigames::isInQueue("kz"))
		sr\minigames\_kz::join();
	else
		sr\minigames\_kz::leave();
}

cmd_KzSpawn(args)
{
	point = spawnStruct();
	point.origin = self getOrigin();
	point.angles = self getPlayerAngles();

	level.kzPoints[level.kzPoints.size] = point;
	self pm("Points placed " + level.kzPoints.size);
}

cmd_KzSave(args)
{
	if (level.kzPoints.size % 2 == 1)
	{
		self pm("^1Points count is not even.");
		return;
	}

	file = FILE_Open(level.files["kz"], "w+");
	for (i = 0; i < level.kzPoints.size; i++)
	{
		origin = level.kzPoints[i].origin;
		angle = level.kzPoints[i].angles[1];

		FILE_WriteLine(file, fmt("%f/%f/%f/%f", origin[0], origin[1], origin[2], angle));
	}
	FILE_Close(file);
	self pm("Points saved");

	sr\minigames\_kz::load();
	self pm("Points loaded");
}

cmd_KzWeapon(args)
{
	if (args.size < 1)
		return self pm("Usage: kz_weapon <name>");

	weapon = args[0];
	sr\minigames\_kz::setWeapon(weapon);
}
