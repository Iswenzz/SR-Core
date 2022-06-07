#include sr\sys\_admins;
#include sr\sys\_file;
#include sr\game\minigames\_kz;

main()
{
	cmd("member", 	"kz",			::cmd_Kz);
    cmd("owner", 	"kz_spawn",		::cmd_KzSpawn);
	cmd("owner", 	"kz_save"		::cmd_KzSave);
	cmd("admin", 	"kz_weapon",	::cmd_KzWeapon);
}

cmd_Kz()
{
	if (self isInOtherQueue("kz"))
	{
		self pm("^1Already in a different mode.");
		return;
	}
	Ternary(!self isInQueue("kz"), join(), leave());
}

cmd_KzSpawn()
{
	point = spawnStruct();
	point.origin = self getOrigin();
	point.angles = self getPlayerAngles();

	level.kzPoints[level.kzPoints.size] = point;
	self pm("Points placed " + level.kzPoints.size);
}

cmd_KzSave()
{
	if (level.kzPoints.size % 2 == 1)
	{
		self pm("^1Points count is not even.");
		return;
	}

	file = FILE_OpenMod(level.files["kz"], "w+");
	for (i = 0; i < level.kzPoints.size; i++)
	{
		origin = level.kzPoints[i].origin;
		angle = level.kzPoints[i].angles[1];

		FILE_WriteLine(file, fmt("%f,%f,%f,%f", origin[0], origin[1], origin[2], angle));
	}
	FILE_Close(file);
	self pm("Points saved");

	load();
	self pm("Points loaded");
}

cmd_KzWeapon(args)
{
	if (args.size < 1)
		return self pm("Usage: kz_weapon <name>");

	weapon = args[0];
	setWeapon(weapon);
}
