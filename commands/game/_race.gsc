#include sr\sys\_file;
#include sr\sys\_admins;
#include sr\game\minigames\_main;
#include sr\game\minigames\_race;

main()
{
    cmd("member", 	"race",			::cmd_Race);
    cmd("admin", 	"race_trig",	::cmd_RaceTrig);
	cmd("admin", 	"race_spawn",	::cmd_RaceSpawn);
	cmd("owner", 	"race_mk",		::cmd_RaceMk);
	cmd("owner", 	"race_save",	::cmd_RaceSave);
}

cmd_Race(args)
{
	if (self isInOtherQueue("race"))
	{
		self pm("^1Already in a different mode.");
		return;
	}
	Ternary(!self isInQueue("race"), join(), leave());
}

cmd_RaceTrig(args)
{
	radius = IfUndef(ToInt(args[0]), 120);

	if (args[0] == "reset")
	{
		level.raceEndTrig = getEnt("endmap_trig", "targetname");
		self pm("Reset race end trigger");
		return;
	}
	if (isDefined(getEnt("race_endtrig", "targetname")))
		getEnt("race_endtrig", "targetname") delete();

	trig = spawn("trigger_radius", self getOrigin(), 0, radius, 80);
	trig.targetname = "race_endtrig";

	level.raceEndTrig = trig;
	self pm("Placed race end trigger");
}

cmd_RaceSpawn(args)
{
	if (args[0] == "reset")
	{
		level.raceSpawn = level.masterspawn;
		self pm("Reset race spawn point");
		return;
	}
	spawn = spawnStruct();
	spawn.origin = self getOrigin();
	spawn.angles = self getPlayerAngles();
	level.raceSpawn = spawn;
}

cmd_RaceMk(args)
{
	level.racePoints[level.racePoints.size] = self GetOrigin();
	self pm("Points placed " + level.racePoints.size);
}

cmd_RaceSave(args)
{
	file = FILE_OpenMod(level.files["race"], "w+");
	for (i = 0; i < level.racePoints.size; i++)
	{
		origin = level.racePoints[i];

		FILE_WriteLine(file, fmt("%f,%f,%f", origin[0], origin[1], origin[2]));
	}
	FILE_Close(file);
	self pm("Points saved");

	load();
	self pm("Points loaded");
}
